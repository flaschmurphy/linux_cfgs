# Shared helpers for setup_security.

BKP_DIR="/var/backups"
DATE="$(date +%Y%m%d%H%M%S)"
REBOOT_REQUIRED=0
DRY_RUN=0
FORCE=0
SKIP_FIREWALL=0
SKIP_UNATTENDED=0
SKIP_FSTAB=0
SKIP_SSHD=0
SKIP_REBOOT_PROMPT=0

declare -a ALLOWED_CIDRS=()

log() {
    printf '%s\n' "$*"
}

die() {
    printf 'ERROR: %s\n' "$*" >&2
    exit 1
}

run() {
    if [[ ${DRY_RUN} -eq 1 ]]; then
        log "[dry-run] $*"
    else
        "$@"
    fi
}

init_allowed_cidrs() {
    local raw=${SECURITY_ALLOWED_CIDRS//,/ }
    ALLOWED_CIDRS=()
    read -r -a ALLOWED_CIDRS <<< "${raw}"
    [[ ${#ALLOWED_CIDRS[@]} -gt 0 ]] || die "SECURITY_ALLOWED_CIDRS must not be empty."
}

get_user_input() {
    local prompt=$1
    local default=$2
    local timeout=$3
    local -n _out=$4
    local err=$5
    local var

    if ! read -r -t "${timeout}" -p "${prompt}" var; then
        log ""
        die "${err}"
    fi
    var=${var:-${default}}
    _out="$(echo "${var}" | tr '[:upper:]' '[:lower:]')"
}

backup_file() {
    local src=$1
    local dest_dir=$2
    local label=$3

    [[ -f ${src} ]] || return 0
    run mkdir -p "${dest_dir}"
    run cp -a "${src}" "${dest_dir}/${label}_${DATE}"
    log "Backed up ${src} to ${dest_dir}/${label}_${DATE}"
}

validate_email() {
    local email=$1
    [[ ${email} =~ ^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$ ]] \
        || die "Invalid email address: ${email}"
}

write_stamp() {
    run mkdir -p "$(dirname "${SECURITY_STAMP_FILE}")"
    if [[ ${DRY_RUN} -eq 1 ]]; then
        log "[dry-run] write stamp ${SECURITY_STAMP_FILE}"
    else
        cat > "${SECURITY_STAMP_FILE}" <<EOF
applied_at=${DATE}
script_dir=${SCRPT_DIR}
allowed_cidrs=${ALLOWED_CIDRS[*]}
ipv6_policy=${SECURITY_IPV6_POLICY}
EOF
        log "Wrote stamp file ${SECURITY_STAMP_FILE}"
    fi
}

check_existing_stamp() {
    [[ ${FORCE} -eq 1 ]] && return 0
    [[ ! -f ${SECURITY_STAMP_FILE} ]] && return 0
    log "Stamp file already exists: ${SECURITY_STAMP_FILE}"
    log "Re-run is safe (idempotent), but use --force to suppress this notice."
}

setup_logging() {
    if [[ ${DRY_RUN} -eq 1 ]]; then
        return 0
    fi
    run mkdir -p "$(dirname "${SECURITY_LOG_FILE}")"
    exec > >(tee -a "${SECURITY_LOG_FILE}") 2>&1
    log "Logging to ${SECURITY_LOG_FILE}"
}
