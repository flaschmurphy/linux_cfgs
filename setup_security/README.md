# setup_security

Basic hardening for Ubuntu/Debian **build servers**. This is not a full security audit; web-facing servers need additional steps.

## What it does

| Step | Changes |
|------|---------|
| Unattended upgrades | Installs `unattended-upgrades`, writes apt drop-ins, runs one upgrade |
| Firewall | Installs `iptables-persistent`, writes `/etc/iptables/rules.v4` and `rules.v6` |
| `/dev/shm` | Adds or updates fstab entry with `noexec,nosuid,nodev` |
| SSH | Writes `/etc/ssh/sshd_config.d/99-linux-cfgs-hardening.conf` |

All changes are **idempotent** — safe to re-run.

## Requirements

- Ubuntu or Debian
- Run as root via sudo from a normal user in the `sudo` group
- That user should have SSH keys in `~/.ssh/authorized_keys` (recommended)

## Usage

```bash
cd setup_security
sudo ./install
```

### Options

```text
--dry-run           Show actions without applying
--force             Skip stamp-file notice on re-run
--skip-firewall     Skip iptables
--skip-unattended   Skip unattended-upgrades
--skip-fstab        Skip fstab changes
--skip-sshd         Skip SSH hardening
--skip-reboot       Do not prompt for reboot
```

### Environment

```bash
export SECURITY_ALLOWED_CIDRS="10.0.0.0/8 192.168.0.0/16"
export SECURITY_IPV6_POLICY="drop"          # or accept_established
export SECURITY_UNATTENDED_EMAIL="you@example.com"
sudo ./install
```

## Rollback

Restores the latest backups under `/var/backups/` and removes linux_cfgs drop-in files:

```bash
sudo ./rollback
```

Backups are timestamped before each change. For manual restore:

```bash
sudo iptables-restore < /var/backups/iptables/ip4tables_bkup_YYYYMMDDhhmmss.txt
```

## Files touched

- `/etc/apt/apt.conf.d/20auto-upgrades`
- `/etc/apt/apt.conf.d/51-linux-cfgs-unattended-mail.conf`
- `/etc/iptables/rules.v4`, `/etc/iptables/rules.v6`
- `/etc/fstab`
- `/etc/ssh/sshd_config.d/99-linux-cfgs-hardening.conf`
- `/var/lib/linux-cfgs-security-applied` (stamp)
- `/var/log/linux-cfgs-security.log`

## Warnings

- Default firewall policy **drops all inbound IPv4** except private CIDRs and established connections.
- Default IPv6 policy **drops all inbound IPv6**. Override with `SECURITY_IPV6_POLICY=accept_established`.
- Ensure console or out-of-band access before applying firewall rules on remote hosts.
