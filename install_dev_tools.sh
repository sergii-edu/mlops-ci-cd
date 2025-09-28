#!/usr/bin/env bash
set -euo pipefail

LOG_FILE="install.log"
exec > >(tee -a "$LOG_FILE") 2>&1

echo "=== $(date -Is) Starting installation ==="

has_cmd() { command -v "$1" >/dev/null 2>&1; }

PKG=""
if has_cmd apt-get; then
  PKG="apt"
elif has_cmd dnf; then
  PKG="dnf"
elif has_cmd yum; then
  PKG="yum"
elif has_cmd pacman; then
  PKG="pacman"
fi

echo "Detected package manager: ${PKG:-none}"

if [[ "${PKG}" == "apt" ]]; then
  sudo apt-get update -y
fi

if ! has_cmd curl; then
  if [[ "${PKG}" == "apt" ]]; then sudo apt-get install -y curl ca-certificates; fi
  if [[ "${PKG}" == "dnf" ]]; then sudo dnf install -y curl ca-certificates; fi
  if [[ "${PKG}" == "yum" ]]; then sudo yum install -y curl ca-certificates; fi
  if [[ "${PKG}" == "pacman" ]]; then sudo pacman -Sy --noconfirm curl ca-certificates; fi
fi

# Docker
if ! has_cmd docker; then
  echo "[Docker] Installing..."
  if [[ "${PKG}" == "apt" ]]; then
    sudo apt-get install -y apt-transport-https gnupg lsb-release
    if [ ! -f /etc/apt/keyrings/docker.gpg ]; then
      sudo install -m 0755 -d /etc/apt/keyrings
      curl -fsSL https://download.docker.com/linux/$(. /etc/os-release; echo "$ID")/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
      sudo chmod a+r /etc/apt/keyrings/docker.gpg
    fi
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") \
      $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
    sudo apt-get update -y
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  else
    echo "Please install Docker manually for your distro."
  fi
else
  echo "[Docker] Already installed: $(docker --version || true)"
fi

# Docker group
if groups "$USER" | grep -qE "\bdocker\b"; then
  echo "[Docker] User already in docker group."
else
  if getent group docker >/dev/null 2>&1; then
    echo "[Docker] Adding $USER to docker group..."
    sudo usermod -aG docker "$USER" || true
    echo "You may need to log out/in for group changes to take effect."
  fi
fi

# Docker Compose v2
if has_cmd docker && docker compose version >/dev/null 2>&1; then
  echo "[Docker Compose] Available via 'docker compose'."
else
  if [[ "${PKG}" == "apt" ]]; then
    sudo apt-get install -y docker-compose-plugin || true
  fi
fi

# Python & pip
if ! has_cmd python3; then
  echo "[Python] Installing..."
  if [[ "${PKG}" == "apt" ]]; then
    sudo apt-get install -y python3 python3-pip python3-venv
  elif [[ "${PKG}" == "dnf" ]]; then
    sudo dnf install -y python3 python3-pip
  elif [[ "${PKG}" == "yum" ]]; then
    sudo yum install -y python3 python3-pip
  elif [[ "${PKG}" == "pacman" ]]; then
    sudo pacman -Sy --noconfirm python python-pip
  fi
fi

if ! has_cmd pip3; then
  curl -fsSL https://bootstrap.pypa.io/get-pip.py | sudo python3
fi

echo "[pip] Using: $(pip3 --version)"

PKGS=("torch" "torchvision" "pillow" "Django")
for p in "${PKGS[@]}"; do
  if python3 -c "import importlib; importlib.import_module('${p}')" 2>/dev/null; then
    echo "[pip] ${p} already installed."
  else
    echo "[pip] Installing ${p}..."
    pip3 install --upgrade --no-cache-dir "${p}"
  fi
done

echo "=== Versions ==="
{
  echo "Docker: $(docker --version 2>/dev/null || echo 'not installed')"
  echo "Docker Compose: $(docker compose version 2>/dev/null || docker-compose --version 2>/dev/null || echo 'not installed')"
  echo "Python: $(python3 --version 2>/dev/null || echo 'not installed')"
  echo "pip: $(pip3 --version 2>/dev/null || echo 'not installed')"
  python3 - <<'PY'
import importlib
for name in ["torch","torchvision","PIL","django"]:
    try:
        m = importlib.import_module(name)
        v = getattr(m, "__version__", "unknown")
        print(f"{name}: {v}")
    except Exception as e:
        print(f"{name}: not installed ({e})")
PY
} | tee -a "$LOG_FILE"

echo "=== $(date -Is) Installation finished ==="
