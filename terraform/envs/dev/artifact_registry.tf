resource "google_artifact_registry_repository" "offline_map" {
  location      = var.region
  repository_id = "offline-map"
  description   = "Docker images for Offline Map project"
  format        = "DOCKER"

  depends_on = [
    google_project_service.services
  ]
}