resource "google_secret_manager_secret" "secret_key" {
  secret_id = "offline-map-secret-key"

  replication {
    auto {}
  }

  depends_on = [
    google_project_service.services
  ]
}

resource "google_secret_manager_secret" "db_password" {
  secret_id = "offline-map-db-password"

  replication {
    auto {}
  }

  depends_on = [
    google_project_service.services
  ]
}

resource "google_secret_manager_secret" "database_url" {
  secret_id = "offline-map-database-url"

  replication {
    auto {}
  }

  depends_on = [
    google_project_service.services
  ]
}

resource "google_secret_manager_secret" "default_admin_password" {
  secret_id = "offline-map-default-admin-password"

  replication {
    auto {}
  }

  depends_on = [
    google_project_service.services
  ]
}