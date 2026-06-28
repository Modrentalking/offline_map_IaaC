output "project_id" {
  value = var.project_id
}

output "region" {
  value = var.region
}

output "artifact_registry_url" {
  value = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.offline_map.repository_id}"
}

output "map_static_bucket" {
  value = google_storage_bucket.map_static.name
}

output "uploads_private_bucket" {
  value = google_storage_bucket.uploads_private.name
}

output "cloud_sql_instance_name" {
  value = google_sql_database_instance.postgres.name
}

output "cloud_sql_connection_name" {
  value = google_sql_database_instance.postgres.connection_name
}

output "gke_cluster_name" {
  value = google_container_cluster.gke.name
}

output "gke_cluster_location" {
  value = google_container_cluster.gke.location
}

output "gke_workload_pool" {
  value = google_container_cluster.gke.workload_identity_config[0].workload_pool
}

output "frontend_global_ip" {
  value = google_compute_global_address.frontend_ip.address
}

output "backend_gsa_email" {
  value = google_service_account.backend.email
}

output "importer_gsa_email" {
  value = google_service_account.importer.email
}

output "migrations_gsa_email" {
  value = google_service_account.migrations.email
}

output "ci_gsa_email" {
  value = google_service_account.ci.email
}
output "map_assets_publisher_gsa_email" {
  value = google_service_account.map_assets_publisher.email
}

output "map_current_pmtiles_url" {
  value = "https://storage.googleapis.com/${google_storage_bucket.map_static.name}/current/belarus.pmtiles"
}

output "map_current_style_url" {
  value = "https://storage.googleapis.com/${google_storage_bucket.map_static.name}/current/styles/simple/style.json"
}
output "github_actions_gsa_email" {
  value = google_service_account.github_actions.email
}

output "github_workload_identity_provider" {
  value = google_iam_workload_identity_pool_provider.github.name
}