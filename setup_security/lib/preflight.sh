# Preflight checks before applying security changes.

check_for_root() {
    [[ ${EUID} -eq 0 ]] || die "Run as root, e.g. sudo ${SCRPT_DIR}/install"
}

require_debian_like() {
    [[ -f /etc/os-release ]] || die "/etc/os-release not found; unsupported OS."
    # shellcheck disable=SC1091
    source /etc/os-release
    [[ ${ID} == "ubuntu" || ${ID} == "debian" ]] \
        || die "Unsupported OS: ${PRETTY_NAME:-unknown}. Ubuntu/Debian only."
    log "Detected OS: ${PRETTY_NAME}"
}

preflight_ssh_access() {
    local admin_user=${SUDO_USER:-}
    local keys_file

    [[ -n ${admin_user} && ${admin_user} != root ]] \
        || die "Run via sudo as a normal user (not root) so lockout checks can run."

    id "${admin_user}" &>/dev/null || die "User ${admin_user} does not exist."

    if ! groups "${admin_user}" | grep -qw sudo; then
        die "User ${admin_user} is not in the sudo group."
    fi

    keys_file="/home/${admin_user}/.ssh/authorized_keys"
    if [[ ! -s ${keys_file} ]]; then
        log "WARNING: No SSH authorized_keys for ${admin_user}."
        local confirm=""
        get_user_input "Continue anyway? You may lock yourself out. [y/N]: " "n" 30 confirm \
            "Timed out waiting for confirmation."
        [[ ${confirm} == "y" ]] || die "Aborted to prevent possible SSH lockout."
    fi
}

print_plan() {
    log ""
    log "This script will:"
    [[ ${SKIP_UNATTENDED} -eq 0 ]] && log "  - Enable unattended security upgrades (non-interactive)"
    [[ ${SKIP_FIREWALL} -eq 0 ]] && log "  - Install persistent iptables rules (private CIDRs only)"
    [[ ${SKIP_FSTAB} -eq 0 ]] && log "  - Harden /dev/shm in /etc/fstab (noexec,nosuid,nodev)"
    [[ ${SKIP_SSHD} -eq 0 ]] && log "  - Disable direct root SSH login via sshd drop-in"
    log ""
    log "Allowed inbound CIDRs: ${ALLOWED_CIDRS[*]}"
    log "IPv6 policy: ${SECURITY_IPV6_POLICY}"
    [[ ${DRY_RUN} -eq 1 ]] && log "DRY RUN: no changes will be applied."
    log ""
}
