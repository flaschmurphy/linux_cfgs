# SSH hardening via drop-in config (idempotent).

reload_sshd() {
    if systemctl list-units --type=service --all 2>/dev/null | grep -q 'ssh\.service'; then
        run systemctl reload ssh
    elif systemctl list-units --type=service --all 2>/dev/null | grep -q 'sshd\.service'; then
        run systemctl reload sshd
    else
        run service ssh reload 2>/dev/null || run service sshd reload
    fi
}

setup_sshd() {
    local dropin=${SECURITY_SSH_DROPIN}
    local dropin_dir

    [[ ${SKIP_SSHD} -eq 0 ]] || return 0

    dropin_dir="$(dirname "${dropin}")"
    backup_file "/etc/ssh/sshd_config" "${BKP_DIR}/sshd_config" "ssh_config"

    if [[ -f ${dropin} ]] \
        && grep -q '^PermitRootLogin no' "${dropin}" 2>/dev/null \
        && grep -q '^MaxAuthTries 3' "${dropin}" 2>/dev/null; then
        log "SSH hardening drop-in already present: ${dropin}"
        return 0
    fi

    log "Writing SSH hardening drop-in to ${dropin}..."
    if [[ ${DRY_RUN} -eq 1 ]]; then
        log "[dry-run] would write ${dropin}"
        return 0
    fi

    run mkdir -p "${dropin_dir}"
    cat > "${dropin}" <<'EOF'
# Managed by linux_cfgs setup_security/install
PermitRootLogin no
PermitEmptyPasswords no
X11Forwarding no
MaxAuthTries 3
EOF

    if ! sshd -t; then
        rm -f "${dropin}"
        die "sshd config validation failed; removed ${dropin}."
    fi

    reload_sshd
    log "Done setting up SSH hardening."
}
