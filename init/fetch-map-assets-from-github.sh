#!/usr/bin/env bash
set -euo pipefail

REPO_RAW_BASE="${REPO_RAW_BASE:-https://raw.githubusercontent.com/Modrentalking/Map/master}"

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

mkdir -p "${ROOT_DIR}/init/tilemaker"
mkdir -p "${ROOT_DIR}/init/styles/simple"
mkdir -p "${ROOT_DIR}/init/styles/simple-dark"
mkdir -p "${ROOT_DIR}/init/styles/empty"
mkdir -p "${ROOT_DIR}/init/styles/osm-bright"
mkdir -p "${ROOT_DIR}/init/data"
mkdir -p "${ROOT_DIR}/init/dist"

touch "${ROOT_DIR}/init/data/.gitkeep"
touch "${ROOT_DIR}/init/dist/.gitkeep"

download_required() {
  local url="$1"
  local output="$2"

  echo "Downloading required:"
  echo "  ${url}"
  echo "→ ${output}"

  wget -q --show-progress --timeout=30 --tries=3 \
    -O "${output}" \
    "${url}"
}

download_optional() {
  local url="$1"
  local output="$2"

  echo "Downloading optional:"
  echo "  ${url}"
  echo "→ ${output}"

  if ! wget -q --show-progress --timeout=30 --tries=3 \
    -O "${output}" \
    "${url}"; then
    echo "WARN: optional file not found, skipping: ${url}"
    rm -f "${output}"
  fi
}

echo "Source repo: ${REPO_RAW_BASE}"
echo

download_required \
  "${REPO_RAW_BASE}/tiles/tilemaker-resources/config-openmaptiles.json" \
  "${ROOT_DIR}/init/tilemaker/config-openmaptiles.json"

download_required \
  "${REPO_RAW_BASE}/tiles/tilemaker-resources/process-openmaptiles.lua" \
  "${ROOT_DIR}/init/tilemaker/process-openmaptiles.lua"

download_required \
  "${REPO_RAW_BASE}/data/styles/simple/style.json" \
  "${ROOT_DIR}/init/styles/simple/style.json"

download_optional \
  "${REPO_RAW_BASE}/data/styles/simple/style-night.json" \
  "${ROOT_DIR}/init/styles/simple/style-night.json"

download_optional \
  "${REPO_RAW_BASE}/data/styles/simple-dark/style.json" \
  "${ROOT_DIR}/init/styles/simple-dark/style.json"

download_optional \
  "${REPO_RAW_BASE}/data/styles/empty/style.json" \
  "${ROOT_DIR}/init/styles/empty/style.json"

download_optional \
  "${REPO_RAW_BASE}/data/styles/osm-bright/style.json" \
  "${ROOT_DIR}/init/styles/osm-bright/style.json"

download_optional \
  "${REPO_RAW_BASE}/data/styles/osm-bright/sprite.json" \
  "${ROOT_DIR}/init/styles/osm-bright/sprite.json"

download_optional \
  "${REPO_RAW_BASE}/data/styles/osm-bright/sprite.png" \
  "${ROOT_DIR}/init/styles/osm-bright/sprite.png"

echo
echo "Done."
echo "Downloaded files:"
find "${ROOT_DIR}/init/tilemaker" "${ROOT_DIR}/init/styles" -type f | sort