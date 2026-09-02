# Default policy for setup_security/install.
# Override before running install, or copy and edit locally.

# Space- or comma-separated private CIDRs allowed to initiate inbound connections.
SECURITY_ALLOWED_CIDRS="${SECURITY_ALLOWED_CIDRS:-10.0.0.0/8 192.168.0.0/16 172.16.0.0/12}"

# drop | accept_established
SECURITY_IPV6_POLICY="${SECURITY_IPV6_POLICY:-drop}"

# Email for unattended-upgrades notifications (empty = prompt with default).
SECURITY_UNATTENDED_EMAIL="${SECURITY_UNATTENDED_EMAIL:-}"

# Stamp written after a successful run.
SECURITY_STAMP_FILE="${SECURITY_STAMP_FILE:-/var/lib/linux-cfgs-security-applied}"

SECURITY_SSH_DROPIN="${SECURITY_SSH_DROPIN:-/etc/ssh/sshd_config.d/99-linux-cfgs-hardening.conf}"

SECURITY_LOG_FILE="${SECURITY_LOG_FILE:-/var/log/linux-cfgs-security.log}"
