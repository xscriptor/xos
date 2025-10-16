#!/usr/bin/env bash
# Auto-start Archinstall for XOs (interactivo, sin JSON)
# - No limpia el MOTD antes de lanzar archinstall
# - Cuenta atrás de 5s con opción a cancelar (Ctrl+C)
# - Ejecuta /root/xos-postinstall.sh al finalizar con éxito

set -euo pipefail

run_xos_postinstall() {
  if [ -x /root/xos-postinstall.sh ]; then
    echo
    echo "→ Ejecutando postinstalación XOs…"
    if /root/xos-postinstall.sh; then
      echo "→ Postinstalación XOs completada."
    else
      echo "[XOs] Postinstalación falló."
      return 1
    fi
  else
    echo "[XOs] Falta /root/xos-postinstall.sh o no es ejecutable."
  fi
}

# 0) Evitar ejecución durante mkarchiso (entorno de build)
if ! grep -q "/run/archiso/bootmnt" /proc/mounts 2>/dev/null; then
  echo "[XOs Build] Detectado entorno de compilación mkarchiso. No se autoinicia."
  return 0 2>/dev/null || exit 0
fi

# Permitir desactivar con variable de entorno
if [ "${XOS_NO_AUTO:-0}" = "1" ]; then
  echo "[XOs] Autoinicio desactivado (XOS_NO_AUTO=1)."
  return 0 2>/dev/null || exit 0
fi

# 1) Solo en TTY1 (no limpiamos pantalla: conservamos MOTD)
if [ "$(tty)" = "/dev/tty1" ]; then
  echo
  echo "──────────────────────────────────────────"
  echo "   XOs Live – Archinstall se iniciará en 5s"
  echo "   Pulsa Ctrl+C para cancelar."
  echo "──────────────────────────────────────────"

  # Cuenta atrás sin limpiar pantalla
  for i in 5 4 3 2 1; do
    printf "\rIniciando archinstall en %s s… (Ctrl+C para cancelar) " "$i"
    sleep 1
  done
  echo
  echo "→ Lanzando archinstall (modo interactivo)…"
  echo

  # 2) Archinstall sin --config (interactivo)
  if archinstall; then
    run_xos_postinstall
  else
    echo "[XOs] archinstall terminó con error; no se ejecuta el postinstall."
  fi
fi
