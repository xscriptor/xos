#!/usr/bin/env bash
set -euo pipefail

# No ejecutarlo durante la build de mkarchiso
grep -q "/run/archiso/bootmnt" /proc/mounts 2>/dev/null || { return 0 2>/dev/null || exit 0; }

# Permitir desactivar
[ "${XOS_NO_AUTO:-0}" = "1" ] && { echo "[XOs] Autoinicio desactivado (XOS_NO_AUTO=1)."; return 0 2>/dev/null || exit 0; }

# Solo en TTY1
[ "$(tty)" = "/dev/tty1" ] || { return 0 2>/dev/null || exit 0; }

echo
echo "──────────────────────────────────────────"
echo "   XOs Live – Archinstall will start in 5s"
echo "   Pulsa Ctrl+C para cancelar."
echo "──────────────────────────────────────────"

for i in 5 4 3 2 1; do
  printf "\rStarting archinstall in %s s… (Ctrl+C to cancel) " "$i"
  sleep 1
done
echo
echo "→ Starting archinstall (Automated with config)…"
echo

CONF_PATH="/root/archinstall_config.json"
CREDS_PATH="/root/user_credentials.json"

if [ -f "$CONF_PATH" ]; then
  if [ -f "$CREDS_PATH" ]; then
    archinstall --config "$CONF_PATH" --creds "$CREDS_PATH"
  else
    archinstall --config "$CONF_PATH"
  fi
else
  archinstall
fi

# Postinstall (branding del sistema instalado)
[ -x /root/xos-postinstall.sh ] && /root/xos-postinstall.sh || true
