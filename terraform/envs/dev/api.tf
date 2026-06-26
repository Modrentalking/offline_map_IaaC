#Enable API
resource "google_project_service" "services" {
  for_each = toset([
    "compute.googleapis.com",
    "container.googleapis.com",
    "artifactregistry.googleapis.com",
    "sqladmin.googleapis.com",
    "storage.googleapis.com",
    "secretmanager.googleapis.com",
    "iam.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "servicenetworking.googleapis.com",
    "dns.googleapis.com",
    "serviceusage.googleapis.com",
  ])

  project = var.project_id
  service = each.key

  # Keep APIs enabled even if Terraform resources are destroyed.
  disable_on_destroy = false
}