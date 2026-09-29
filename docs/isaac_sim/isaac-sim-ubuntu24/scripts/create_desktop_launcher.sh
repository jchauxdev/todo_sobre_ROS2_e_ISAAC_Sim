#!/usr/bin/env bash
# Crea un lanzador de Isaac Sim en el menú de aplicaciones de Ubuntu
# Uso: ./scripts/create_desktop_launcher.sh [carpeta_isaac_sim]
#   Por defecto: ~/isaacsim

set -euo pipefail
ISAAC_DIR="$(realpath "${1:-$HOME/isaacsim}")"

if [[ ! -x "$ISAAC_DIR/isaac-sim.sh" ]]; then
  echo "No se encontró $ISAAC_DIR/isaac-sim.sh. Pasa la carpeta correcta como argumento."
  exit 1
fi

APPS="$HOME/.local/share/applications"
mkdir -p "$APPS"

write_launcher () {  # $1=archivo $2=nombre $3=script
  cat > "$APPS/$1" <<EOF
[Desktop Entry]
Type=Application
Name=$2
Exec=$ISAAC_DIR/$3
Path=$ISAAC_DIR
Terminal=true
Icon=applications-science
Categories=Development;Science;
EOF
  chmod +x "$APPS/$1"
}

write_launcher isaac-sim.desktop "Isaac Sim 6.1" isaac-sim.sh
write_launcher isaac-sim-compat.desktop "Isaac Sim Compatibility Checker" isaac-sim.compatibility_check.sh

update-desktop-database "$APPS" 2>/dev/null || true
echo "Lanzadores creados en $APPS"
echo "Busca 'Isaac Sim' en el menú de aplicaciones (tecla Super)."
