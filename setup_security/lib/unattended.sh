# Unattended security upgrades (non-interactive, idempotent).

setup_auto_update() {
    local email default dst mail_conf

    [[ ${SKIP_UNATTENDED} -eq 1 ]] && return 0

    default="${SUDO_USER:-root}@localhost"
    email=${SECURITY_UNATTENDED_EMAIL}
    if [[ -z ${email} ]]; then
        get_user_input \
            "Enter email for unattended-upgrade notifications [${default}]: " \
            "${default}" 60 email \
            "Timed out; using default ${default}."
    fi
    validate_email "${email}"

    log "Configuring unattended-upgrades..."
    export DEBIAN_FRONTEND=noninteractive
    run apt-get update
    run apt-get install -y unattended-upgrades apt-listchanges

    dst="${BKP_DIR}/unattended-upgrades"
    backup_file "/etc/apt/apt.conf.d/50unattended-upgrades" "${dst}" "50unattended-upgrades"

    run tee /etc/apt/apt.conf.d/20auto-upgrades >/dev/null <<'EOF'
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Unattended-Upgrade "1";
APT::Periodic::AutocleanInterval "7";
EOF

    mail_conf="/etc/apt/apt.conf.d/51-linux-cfgs-unattended-mail.conf"
    if [[ ${DRY_RUN} -eq 1 ]]; then
        log "[dry-run] write ${mail_conf} with Mail=${email}"
    else
        printf 'Unattended-Upgrade::Mail "%s";\n' "${email}" > "${mail_conf}"
    fi
    log "Notification email: ${email}"

    if command -v unattended-upgrade >/dev/null 2>&1; then
        run unattended-upgrade -v
    else
        run unattended-upgrades -v
    fi

    log "Done setting up unattended-upgrades."
}
