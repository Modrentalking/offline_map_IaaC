#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

ENV_DIR="${ENV_DIR:-terraform/envs/dev}"
TF_DIR="${ROOT_DIR}/${ENV_DIR}"
ENV_FILE="${ENV_FILE:-${ROOT_DIR}/.env}"

DOMAIN="${DOMAIN:-new.map.of.by}"
IMAGE_NAME="${IMAGE_NAME:-offline-map-mapbuilder:local}"

if ! command -v terraform >/dev/null 2>&1; then
  echo "ERROR: terraform not found"
  exit 1
fi

if [[ ! -d "${TF_DIR}" ]]; then
  echo "ERROR: Terraform directory not found: ${TF_DIR}"
  exit 1
fi

tf_output() {
  local name="$1"
  terraform -chdir="${TF_DIR}" output -raw "${name}" 2>/dev/null || true
}

PROJECT_ID="$(tf_output project_id)"
REGION="$(tf_output region)"
MAP_BUCKET="$(tf_output map_static_bucket)"
PUBLISHER_SA="$(tf_output map_assets_publisher_gsa_email)"
FRONTEND_GLOBAL_IP="$(tf_output frontend_global_ip)"
CLOUD_SQL_CONNECTION_NAME="$(tf_output cloud_sql_connection_name)"
ARTIFACT_REGISTRY_URL="$(tf_output artifact_registry_url)"

if [[ -z "${PROJECT_ID}" ]]; then
  PROJECT_ID="offline-map-prod"
fi

if [[ -z "${REGION}" ]]; then
  REGION="europe-west3"
fi

if [[ -z "${MAP_BUCKET}" ]]; then
  echo "ERROR: Terraform output map_static_bucket is empty"
  echo "Run terraform apply first."
  exit 1
fi

if [[ -z "${PUBLISHER_SA}" ]]; then
  PUBLISHER_SA="offline-map-assets-publisher@${PROJECT_ID}.iam.gserviceaccount.com"
fi

PMTILES_URL="https://storage.googleapis.com/${MAP_BUCKET}/current/belarus.pmtiles"
STYLE_URL="https://storage.googleapis.com/${MAP_BUCKET}/current/styles/simple/style.json"
MANIFEST_URL="https://storage.googleapis.com/${MAP_BUCKET}/manifest.json"

cat > "${ENV_FILE}" <<EOF
# Generated from Terraform outputs.
# Do not store secrets here.

PROJECT_ID="${PROJECT_ID}"
REGION="${REGION}"
ENV_DIR="${ENV_DIR}"

DOMAIN="${DOMAIN}"
FRONTEND_GLOBAL_IP="${FRONTEND_GLOBAL_IP}"

MAP_BUCKET="${MAP_BUCKET}"
PUBLISHER_SA="${PUBLISHER_SA}"

PMTILES_URL="${PMTILES_URL}"
STYLE_URL="${STYLE_URL}"
MANIFEST_URL="${MANIFEST_URL}"

CLOUD_SQL_CONNECTION_NAME="${CLOUD_SQL_CONNECTION_NAME}"
ARTIFACT_REGISTRY_URL="${ARTIFACT_REGISTRY_URL}"

PBF_FILE="init/data/belarus-latest.osm.pbf"
DIST_DIR="init/dist"
PMTILES_FILE="init/dist/belarus.pmtiles"

IMAGE_NAME="${IMAGE_NAME}"

TILEMAKER_CONFIG="init/tilemaker/config-openmaptiles.json"
TILEMAKER_PROCESS="init/tilemaker/process-openmaptiles.lua"
PBF_URL="https://download.geofabrik.de/europe/belarus-latest.osm.pbf"
PBF_MD5_URL="https://download.geofabrik.de/europe/belarus-latest.osm.pbf.md5"
FORCE_DOWNLOAD_PBF="false"
PMTILES_IMAGE="protomaps/go-pmtiles:latest"
TILEMAKER_IMAGE="ghcr.io/systemed/tilemaker:master"
EOF

echo "Created ${ENV_FILE}"
echo
echo "MAP_BUCKET=${MAP_BUCKET}"
echo "PUBLISHER_SA=${PUBLISHER_SA}"
echo "PMTILES_URL=${PMTILES_URL}"
echo "STYLE_URL=${STYLE_URL}"
