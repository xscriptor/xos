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
echo "   XOs Live – Archinstall se iniciará en 5s"
echo "   Pulsa Ctrl+C para cancelar."
echo "──────────────────────────────────────────"

for i in 5 4 3 2 1; do
  printf "\rIniciando archinstall en %s s… (Ctrl+C para cancelar) " "$i"
  sleep 1
done
echo
echo "→ Lanzando archinstall (modo interactivo)…"
echo

archinstall

# Postinstall (branding del sistema instalado)
[ -x /root/xos-postinstall.sh ] && /root/xos-postinstall.sh || true
