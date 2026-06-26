#Terraform state bucket
terraform {
  backend "gcs" {
    bucket = "offline-map-prod-terraform-state"
    prefix = "envs/dev"
  }
}
