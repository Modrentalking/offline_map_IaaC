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