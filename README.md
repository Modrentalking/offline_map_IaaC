# Offline Map IaaC

Terraform infrastructure for running the **Offline Map** project on Google Cloud Platform.

## Current Status

The base cloud infrastructure is ready:

* Terraform remote state
* GitHub Actions CI/CD for Terraform
* GKE Autopilot
* Cloud SQL PostgreSQL
* Artifact Registry
* GCS buckets for map assets and uploads
* Secret Manager
* IAM and Workload Identity
* Global static IP for future Ingress

## Structure

```text
terraform/
├── bootstrap/   # remote state, GitHub Actions identity, WIF
├── envs/dev/    # application infrastructure
└── modules/     # future reusable modules

init/            # map assets build and publish scripts
.github/
└── workflows/   # GitHub Actions pipelines
```

## Terraform

### Bootstrap

Bootstrap creates the base resources required for CI/CD:

* Terraform state bucket
* GitHub Actions service account
* Workload Identity Federation
* IAM permissions for Terraform automation

Run locally:

```bash
cd terraform/bootstrap
terraform init
terraform plan
terraform apply
```

### Dev environment

Dev creates the application infrastructure:

```bash
cd terraform/envs/dev
terraform init
terraform plan
terraform apply
```

## GitHub Actions

Terraform workflow:

```text
push to master
  → terraform plan

manual workflow_dispatch
  → terraform plan
  → manual approval
  → terraform apply
```

Required GitHub Variables:

```text
GCP_PROJECT_ID
GCP_REGION
GCP_SERVICE_ACCOUNT
GCP_WORKLOAD_IDENTITY_PROVIDER
TF_STATE_BUCKET
```

Required GitHub Secrets:

```text
DB_PASSWORD
```

## Map Assets Init

The `init/` directory is used to build and publish map assets to GCS.

It can:

* download style and tilemaker resources
* download Belarus OSM PBF
* build PMTiles
* publish PMTiles, styles and manifest to the map-static bucket

Generate local `.env` from Terraform outputs:

```bash
./init/generate-env-from-terraform.sh
```

Run full local flow:

```bash
FORCE_DOWNLOAD_PBF=true ./init/build-and-publish.sh
```

Main output URLs:

```text
PMTILES_URL
STYLE_URL
MANIFEST_URL
```

Map assets are published by the dedicated service account:

```text
offline-map-assets-publisher
```
