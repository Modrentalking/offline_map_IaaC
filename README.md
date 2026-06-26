# Offline Map IaaC

Terraform infrastructure for running the **Offline Map** project on Google Cloud Platform.

## Resources Created

- VPC and subnet for GKE
- Private Service Access for Cloud SQL
- Cloud SQL PostgreSQL
- GKE Autopilot
- Artifact Registry
- GCS buckets for map assets and uploads
- Secret Manager
- IAM and Workload Identity
- Global static IP for Ingress

## Structure

```text
terraform/
├── bootstrap/   # bucket for Terraform remote state
├── envs/dev/    # dev infrastructure
└── modules/     # future modules

## Map assets

The `init/` directory is used to build and publish map assets to GCS.

It can:

* download style and tilemaker files
* download fresh Belarus OSM PBF
* build PMTiles
* upload PMTiles and styles to the `map-static` bucket

### Usage

Generate local `.env` from Terraform outputs:

```bash
./init/generate-env-from-terraform.sh
```

Download style and tilemaker resources:

```bash
./init/fetch-map-assets-from-github.sh
```

Build PMTiles:

```bash
./init/build-map.sh
```

Force fresh PBF download:

```bash
FORCE_DOWNLOAD_PBF=true ./init/build-map.sh
```

Publish assets to GCS:

```bash
./init/publish-map-assets.sh
```

Or run full flow:

```bash
FORCE_DOWNLOAD_PBF=true ./init/build-and-publish.sh
```

### Output

Assets are uploaded to:

```text
gs://<map-static-bucket>/current/
gs://<map-static-bucket>/releases/<release-id>/
```

Main URLs are stored in `.env`:

```text
PMTILES_URL
STYLE_URL
MANIFEST_URL
```

### Check

```bash
source .env

curl -I "${STYLE_URL}"

curl -H "Range: bytes=0-1023" -I "${PMTILES_URL}"
```

Expected:

```text
HTTP 200 for style.json
HTTP 206 for PMTiles
```

Map assets are uploaded by the dedicated service account:

```text
offline-map-assets-publisher
```
