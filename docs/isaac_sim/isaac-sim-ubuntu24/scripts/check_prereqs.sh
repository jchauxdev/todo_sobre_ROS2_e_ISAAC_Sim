#!/usr/bin/env bash
# Verificación rápida de requisitos antes de instalar Isaac Sim 6.1.0 en Ubuntu 24.04
# Uso: ./scripts/check_prereqs.sh

set -u
OK="\e[32m[OK]\e[0m"; WARN="\e[33m[AVISO]\e[0m"; FAIL="\e[31m[FALLA]\e[0m"

echo "== Sistema operativo =="
if command -v lsb_release >/dev/null; then
  DISTRO=$(lsb_release -ds)
  echo -e "$OK $DISTRO"
  [[ "$DISTRO" == *"24.04"* || "$DISTRO" == *"22.04"* ]] || echo -e "$WARN Versión de Ubuntu no probada oficialmente"
else
  echo -e "$WARN lsb_release no disponible"; cat /etc/os-release | head -2
fi
echo "   Arquitectura: $(uname -m)"

echo; echo "== Driver NVIDIA y GPUs =="
if command -v nvidia-smi >/dev/null; then
  nvidia-smi --query-gpu=index,name,driver_version,memory.total --format=csv,noheader | \
    while IFS=, read -r idx name drv mem; do echo -e "$OK GPU$idx:$name | driver$drv | VRAM$mem"; done
else
  echo -e "$FAIL nvidia-smi no encontrado: instala el driver NVIDIA (sudo ubuntu-drivers install)"
fi

echo; echo "== CPU =="
echo "   $(lscpu | grep 'Model name' | sed 's/Model name:\s*//')"
CORES=$(nproc)
if (( CORES >= 16 )); then echo -e "$OK $CORES hilos"; else echo -e "$WARN $CORES hilos (se recomiendan 16 o más)"; fi

echo; echo "== RAM =="
RAM_GB=$(free -g | awk '/Mem:/ {print $2}')
if (( RAM_GB >= 32 )); then echo -e "$OK ${RAM_GB} GB"; else echo -e "$WARN ${RAM_GB} GB (mínimo 32 GB, recomendado 64 GB)"; fi

echo; echo "== Disco libre en \$HOME =="
DISK_GB=$(df -BG --output=avail "$HOME" | tail -1 | tr -dc '0-9')
if (( DISK_GB >= 50 )); then echo -e "$OK ${DISK_GB} GB libres"; else echo -e "$WARN ${DISK_GB} GB libres (se recomiendan 50 GB o más)"; fi

echo; echo "== Herramientas =="
for t in unzip python3; do
  if command -v $t >/dev/null; then echo -e "$OK $t"; else echo -e "$FAIL falta $t (sudo apt install $t)"; fi
done
