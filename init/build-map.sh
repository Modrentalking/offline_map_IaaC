#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/env.sh"

require_cmd docker
require_cmd wget

PBF_URL="${PBF_URL:-https://download.geofabrik.de/europe/belarus-latest.osm.pbf}"
PBF_MD5_URL="${PBF_MD5_URL:-${PBF_URL}.md5}"
FORCE_DOWNLOAD_PBF="${FORCE_DOWNLOAD_PBF:-false}"

TILEMAKER_IMAGE="${TILEMAKER_IMAGE:-ghcr.io/systemed/tilemaker:master}"

PBF_ABS="$(abs_path "${PBF_FILE}")"
PBF_DIR="$(dirname "${PBF_ABS}")"

DIST_ABS="$(abs_path "${DIST_DIR}")"
PMTILES_FILE="${DIST_DIR}/belarus.pmtiles"
PMTILES_ABS="$(abs_path "${PMTILES_FILE}")"

TILEMAKER_CONFIG_ABS="$(abs_path "${TILEMAKER_CONFIG}")"
TILEMAKER_PROCESS_ABS="$(abs_path "${TILEMAKER_PROCESS}")"

download_pbf() {
  mkdir -p "${PBF_DIR}"

  if [[ -f "${PBF_ABS}" && "${FORCE_DOWNLOAD_PBF}" != "true" ]]; then
    echo "PBF already exists: ${PBF_FILE}"
    echo "Use FORCE_DOWNLOAD_PBF=true ./init/build-map.sh to download fresh file."
    return
  fi

  echo "Downloading fresh PBF..."
  echo "URL: ${PBF_URL}"
  echo "Output: ${PBF_FILE}"

  wget --continue --show-progress --timeout=60 --tries=3 \
    -O "${PBF_ABS}" \
    "${PBF_URL}"

  echo "Downloading MD5..."
  if wget -q --timeout=30 --tries=3 \
    -O "${PBF_ABS}.md5" \
    "${PBF_MD5_URL}"; then
    echo "Verifying MD5..."
    (
      cd "${PBF_DIR}"
      md5sum -c "$(basename "${PBF_ABS}").md5"
    )
  else
    echo "WARN: MD5 file was not downloaded, skipping checksum verification."
  fi
}

download_pbf

if [[ ! -f "${PBF_ABS}" ]]; then
  echo "ERROR: PBF file not found: ${PBF_FILE}"
  exit 1
fi

if [[ ! -f "${TILEMAKER_CONFIG_ABS}" ]]; then
  echo "ERROR: tilemaker config not found: ${TILEMAKER_CONFIG}"
  echo "Run ./init/fetch-map-assets-from-github.sh first."
  exit 1
fi

if [[ ! -f "${TILEMAKER_PROCESS_ABS}" ]]; then
  echo "ERROR: tilemaker process file not found: ${TILEMAKER_PROCESS}"
  echo "Run ./init/fetch-map-assets-from-github.sh first."
  exit 1
fi

mkdir -p "${DIST_ABS}"

echo "Removing old PMTiles if exists..."
rm -f "${PMTILES_ABS}"

echo "Pulling tilemaker image..."
docker pull "${TILEMAKER_IMAGE}"

echo "Generating PMTiles directly..."
docker run --rm \
  -v "${ROOT_DIR}:/work" \
  "${TILEMAKER_IMAGE}" \
  "/work/${PBF_FILE}" \
  --output "/work/${PMTILES_FILE}" \
  --config "/work/${TILEMAKER_CONFIG}" \
  --process "/work/${TILEMAKER_PROCESS}"

echo
echo "Done."
echo "PMTiles: ${PMTILES_FILE}"
ls -lh "${PMTILES_ABS}"