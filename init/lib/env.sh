#!/usr/bin/env bash

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
ENV_FILE="${ENV_FILE:-${ROOT_DIR}/.env}"

if [[ -f "${ENV_FILE}" ]]; then
  set -a
  # shellcheck disable=SC1090
  source "${ENV_FILE}"
  set +a
fi

PROJECT_ID="${PROJECT_ID:-offline-map-prod}"
REGION="${REGION:-europe-west3}"
ENV_DIR="${ENV_DIR:-terraform/envs/dev}"
DOMAIN="${DOMAIN:-new.map.of.by}"

TF_DIR="${ROOT_DIR}/${ENV_DIR}"

PBF_FILE="${PBF_FILE:-init/data/belarus-latest.osm.pbf}"
DIST_DIR="${DIST_DIR:-init/dist}"
PMTILES_FILE="${PMTILES_FILE:-init/dist/belarus.pmtiles}"

IMAGE_NAME="${IMAGE_NAME:-offline-map-mapbuilder:local}"

TILEMAKER_CONFIG="${TILEMAKER_CONFIG:-init/tilemaker/config-openmaptiles.json}"
TILEMAKER_PROCESS="${TILEMAKER_PROCESS:-init/tilemaker/process-openmaptiles.lua}"

MAP_BUCKET="${MAP_BUCKET:-}"
PUBLISHER_SA="${PUBLISHER_SA:-}"

RELEASE_ID="${RELEASE_ID:-$(date +%Y%m%d-%H%M%S)}"

abs_path() {
  local path="$1"

  if [[ "${path}" = /* ]]; then
    echo "${path}"
  else
    echo "${ROOT_DIR}/${path}"
  fi
}

require_cmd() {
  local cmd="$1"

  if ! command -v "${cmd}" >/dev/null 2>&1; then
    echo "ERROR: required command not found: ${cmd}"
    exit 1
  fi
}