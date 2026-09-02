# Harden shared memory mount in /etc/fstab (idempotent).

SHM_MOUNT="/dev/shm"
SHM_OPTS="defaults,noexec,nosuid,nodev"

setup_fstab() {
    local fstab_bkp_root tmp_file

    [[ ${SKIP_FSTAB} -eq 0 ]] || return 0

    fstab_bkp_root="${BKP_DIR}/fstab"
    backup_file "/etc/fstab" "${fstab_bkp_root}" "fstab_bkp"

    if grep -qE "^[^#[:space:]].*[[:space:]]${SHM_MOUNT}[[:space:]]" /etc/fstab; then
        if grep -qE "^[^#[:space:]].*[[:space:]]${SHM_MOUNT}[[:space:]].*noexec.*nosuid.*nodev" /etc/fstab; then
            log "${SHM_MOUNT} already hardened in /etc/fstab."
            return 0
        fi
        log "Updating existing ${SHM_MOUNT} entry in /etc/fstab..."
        tmp_file="$(mktemp)"
        awk -v mp="${SHM_MOUNT}" -v opts="${SHM_OPTS}" '
            $0 ~ "^[[:space:]]*#" { print; next }
            $2 == mp && $3 == "tmpfs" {
                $4 = opts
            }
            { print }
        ' /etc/fstab > "${tmp_file}"
        if [[ ${DRY_RUN} -eq 1 ]]; then
            log "[dry-run] would update /etc/fstab for ${SHM_MOUNT}"
            rm -f "${tmp_file}"
            return 0
        fi
        install -m 644 "${tmp_file}" /etc/fstab
        rm -f "${tmp_file}"
    else
        log "Adding ${SHM_MOUNT} entry to /etc/fstab..."
        if [[ ${DRY_RUN} -eq 1 ]]; then
            log "[dry-run] would append tmpfs ${SHM_MOUNT} to /etc/fstab"
            return 0
        fi
        printf 'tmpfs %s tmpfs %s 0 0\n' "${SHM_MOUNT}" "${SHM_OPTS}" >> /etc/fstab
    fi

    REBOOT_REQUIRED=1
    log "Done setting up fstab."
}
