resource "google_service_account" "backend" {
  account_id   = "offline-map-backend"
  display_name = "Offline Map Backend"
}

resource "google_service_account" "importer" {
  account_id   = "offline-map-importer"
  display_name = "Offline Map Importer"
}

resource "google_service_account" "migrations" {
  account_id   = "offline-map-migrations"
  display_name = "Offline Map Migrations"
}

resource "google_service_account" "ci" {
  account_id   = "offline-map-ci"
  display_name = "Offline Map CI"
}

#Backed access
resource "google_project_iam_member" "backend_cloudsql_client" {
  project = var.project_id
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${google_service_account.backend.email}"
}

resource "google_project_iam_member" "backend_secret_accessor" {
  project = var.project_id
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${google_service_account.backend.email}"
}

resource "google_storage_bucket_iam_member" "backend_uploads_admin" {
  bucket = google_storage_bucket.uploads_private.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.backend.email}"
}
#Importer access
resource "google_project_iam_member" "importer_cloudsql_client" {
  project = var.project_id
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${google_service_account.importer.email}"
}

resource "google_project_iam_member" "importer_secret_accessor" {
  project = var.project_id
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${google_service_account.importer.email}"
}

resource "google_storage_bucket_iam_member" "importer_uploads_viewer" {
  bucket = google_storage_bucket.uploads_private.name
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${google_service_account.importer.email}"
}
#Migrations access
resource "google_project_iam_member" "migrations_cloudsql_client" {
  project = var.project_id
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${google_service_account.migrations.email}"
}

resource "google_project_iam_member" "migrations_secret_accessor" {
  project = var.project_id
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${google_service_account.migrations.email}"
}
#CI access
resource "google_project_iam_member" "ci_artifact_registry_writer" {
  project = var.project_id
  role    = "roles/artifactregistry.writer"
  member  = "serviceAccount:${google_service_account.ci.email}"
}

locals {
  k8s_namespace          = "offline-map"
  workload_identity_pool = "${var.project_id}.svc.id.goog"
}

resource "google_service_account_iam_member" "backend_workload_identity" {
  service_account_id = google_service_account.backend.name
  role               = "roles/iam.workloadIdentityUser"

  member = "serviceAccount:${local.workload_identity_pool}[${local.k8s_namespace}/backend]"
}

resource "google_service_account_iam_member" "importer_workload_identity" {
  service_account_id = google_service_account.importer.name
  role               = "roles/iam.workloadIdentityUser"

  member = "serviceAccount:${local.workload_identity_pool}[${local.k8s_namespace}/importer]"
}

resource "google_service_account_iam_member" "migrations_workload_identity" {
  service_account_id = google_service_account.migrations.name
  role               = "roles/iam.workloadIdentityUser"

  member = "serviceAccount:${local.workload_identity_pool}[${local.k8s_namespace}/migrations]"
}
#
resource "google_service_account" "map_assets_publisher" {
  account_id   = "offline-map-assets-publisher"
  display_name = "Offline Map Assets Publisher"
}

resource "google_storage_bucket_iam_member" "map_assets_publisher_object_admin" {
  bucket = google_storage_bucket.map_static.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.map_assets_publisher.email}"
}

resource "google_storage_bucket_iam_member" "map_static_public_read" {
  bucket = google_storage_bucket.map_static.name
  role   = "roles/storage.objectViewer"
  member = "allUsers"
}

resource "google_service_account_iam_member" "map_assets_publisher_impersonation" {
  for_each = toset(var.map_assets_publishers)

  service_account_id = google_service_account.map_assets_publisher.name
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = each.value
}
resource "google_storage_bucket_iam_member" "map_assets_publisher_legacy_bucket_reader" {
  bucket = google_storage_bucket.map_static.name
  role   = "roles/storage.legacyBucketReader"
  member = "serviceAccount:${google_service_account.map_assets_publisher.email}"
}