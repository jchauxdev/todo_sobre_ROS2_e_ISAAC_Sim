#!/usr/bin/env bash
# Descomprime Isaac Sim 6.1.0 (standalone) y ejecuta post_install.sh
# Uso: ./scripts/install_isaac_sim.sh [ruta_zip] [carpeta_destino]
#   Por defecto: ~/Downloads/isaac-sim-standalone-6.1.0-linux-x86_64.zip  ->  ~/isaacsim

set -euo pipefail
ZIP="${1:-$HOME/Downloads/isaac-sim-standalone-6.1.0-linux-x86_64.zip}"
DEST="${2:-$HOME/isaacsim}"

if [[ ! -f "$ZIP" ]]; then
  echo "No se encontró el zip: $ZIP"
  echo "Descárgalo desde https://docs.isaacsim.omniverse.nvidia.com/6.1.0/installation/download.html"
  exit 1
fi

if [[ -d "$DEST" && -n "$(ls -A "$DEST" 2>/dev/null)" ]]; then
  echo "La carpeta $DEST ya existe y no está vacía. Bórrala o elige otro destino."
  exit 1
fi

mkdir -p "$DEST"
echo ">> Descomprimiendo en $DEST (puede tardar unos minutos)..."
unzip -q "$ZIP" -d "$DEST"

cd "$DEST"
echo ">> Ejecutando post_install.sh..."
./post_install.sh

echo
echo "Instalación lista en: $DEST"
echo "  Comprobar compatibilidad:  cd $DEST && ./isaac-sim.compatibility_check.sh"
echo "  Lanzar Isaac Sim:          cd $DEST && ./isaac-sim.sh"
