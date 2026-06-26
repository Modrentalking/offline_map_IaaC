#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/env.sh"

require_cmd gcloud
require_cmd terraform
require_cmd python3

if [[ -z "${MAP_BUCKET}" ]]; then
  echo "ERROR: MAP_BUCKET is empty."
  echo "Run ./init/generate-env-from-terraform.sh first."
  exit 1
fi

if [[ -z "${PUBLISHER_SA}" ]]; then
  echo "ERROR: PUBLISHER_SA is empty."
  echo "Run ./init/generate-env-from-terraform.sh first."
  exit 1
fi

PMTILES_ABS="$(abs_path "${PMTILES_FILE}")"
DIST_ABS="$(abs_path "${DIST_DIR}")"

if [[ ! -f "${PMTILES_ABS}" ]]; then
  echo "ERROR: PMTiles file not found: ${PMTILES_FILE}"
  echo "Run ./init/build-map.sh first."
  exit 1
fi

SRC_STYLES_DIR="${ROOT_DIR}/init/styles"
DIST_STYLES_DIR="${DIST_ABS}/styles"

if [[ ! -d "${SRC_STYLES_DIR}" ]]; then
  echo "ERROR: styles directory not found: ${SRC_STYLES_DIR}"
  echo "Run ./init/fetch-map-assets-from-github.sh first."
  exit 1
fi

rm -rf "${DIST_STYLES_DIR}"
mkdir -p "${DIST_STYLES_DIR}"

PMTILES_PUBLIC_URL="https://storage.googleapis.com/${MAP_BUCKET}/current/belarus.pmtiles"

patch_style_json() {
  local src="$1"
  local dst="$2"
  local pmtiles_url="$3"

  python3 - "$src" "$dst" "$pmtiles_url" <<'PY'
import json
import sys
from pathlib import Path

src = Path(sys.argv[1])
dst = Path(sys.argv[2])
pmtiles_url = sys.argv[3]

with src.open("r", encoding="utf-8") as f:
    style = json.load(f)

sources = style.get("sources", {})
patched = False

for _, source in sources.items():
    if source.get("type") == "vector":
        source.pop("tiles", None)
        source["url"] = f"pmtiles://{pmtiles_url}"
        patched = True

dst.parent.mkdir(parents=True, exist_ok=True)

with dst.open("w", encoding="utf-8") as f:
    json.dump(style, f, ensure_ascii=False, indent=2)
    f.write("\n")

if patched:
    print(f"patched vector source: {src}")
else:
    print(f"copied without vector patch: {src}")
PY
}

echo "Preparing styles..."

for style_dir in "${SRC_STYLES_DIR}"/*; do
  [[ -d "${style_dir}" ]] || continue

  style_name="$(basename "${style_dir}")"
  target_dir="${DIST_STYLES_DIR}/${style_name}"

  mkdir -p "${target_dir}"

  find "${style_dir}" -maxdepth 1 -type f | while read -r file; do
    base="$(basename "${file}")"

    case "${base}" in
      style.json|style-night.json)
        patch_style_json "${file}" "${target_dir}/${base}" "${PMTILES_PUBLIC_URL}"
        ;;
      *)
        cp "${file}" "${target_dir}/${base}"
        ;;
    esac
  done
done

echo
echo "Project: ${PROJECT_ID}"
echo "Bucket: gs://${MAP_BUCKET}"
echo "Publisher SA: ${PUBLISHER_SA}"
echo "Release: ${RELEASE_ID}"
echo "PMTiles URL: ${PMTILES_PUBLIC_URL}"
echo

echo "Uploading release PMTiles..."
gcloud storage cp "${PMTILES_ABS}" \
  "gs://${MAP_BUCKET}/releases/${RELEASE_ID}/belarus.pmtiles" \
  --project="${PROJECT_ID}" \
  --impersonate-service-account="${PUBLISHER_SA}"

echo "Uploading current PMTiles..."
gcloud storage cp "${PMTILES_ABS}" \
  "gs://${MAP_BUCKET}/current/belarus.pmtiles" \
  --project="${PROJECT_ID}" \
  --impersonate-service-account="${PUBLISHER_SA}"

echo "Uploading release styles..."
gcloud storage cp --recursive "${DIST_STYLES_DIR}" \
  "gs://${MAP_BUCKET}/releases/${RELEASE_ID}/styles" \
  --project="${PROJECT_ID}" \
  --impersonate-service-account="${PUBLISHER_SA}"

echo "Uploading current styles..."
gcloud storage cp --recursive "${DIST_STYLES_DIR}" \
  "gs://${MAP_BUCKET}/current/styles" \
  --project="${PROJECT_ID}" \
  --impersonate-service-account="${PUBLISHER_SA}"

MANIFEST_FILE="$(mktemp)"

cat > "${MANIFEST_FILE}" <<EOF
{
  "release_id": "${RELEASE_ID}",
  "domain": "${DOMAIN}",
  "pmtiles_url": "https://storage.googleapis.com/${MAP_BUCKET}/current/belarus.pmtiles",
  "style_url": "https://storage.googleapis.com/${MAP_BUCKET}/current/styles/simple/style.json",
  "style_night_url": "https://storage.googleapis.com/${MAP_BUCKET}/current/styles/simple/style-night.json",
  "empty_style_url": "https://storage.googleapis.com/${MAP_BUCKET}/current/styles/empty/style.json",
  "osm_bright_style_url": "https://storage.googleapis.com/${MAP_BUCKET}/current/styles/osm-bright/style.json"
}
EOF

echo "Uploading manifest..."
gcloud storage cp "${MANIFEST_FILE}" \
  "gs://${MAP_BUCKET}/manifest.json" \
  --project="${PROJECT_ID}" \
  --impersonate-service-account="${PUBLISHER_SA}"

rm -f "${MANIFEST_FILE}"

echo
echo "Done."
echo "PMTiles:"
echo "https://storage.googleapis.com/${MAP_BUCKET}/current/belarus.pmtiles"
echo
echo "Style:"
echo "https://storage.googleapis.com/${MAP_BUCKET}/current/styles/simple/style.json"
echo
echo "Manifest:"
echo "https://storage.googleapis.com/${MAP_BUCKET}/manifest.json"
