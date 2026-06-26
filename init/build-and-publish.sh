#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/env.sh"

"${ROOT_DIR}/init/build-map.sh"
"${ROOT_DIR}/init/publish-map-assets.sh"
