#Bucket for tiles and static files
resource "google_storage_bucket" "map_static" {
  name                        = "${var.project_id}-map-static"
  location                    = var.region
  uniform_bucket_level_access = true

  cors {
    origin = var.map_cors_origins

    method = [
      "GET",
      "HEAD",
      "OPTIONS"
    ]

    response_header = [
      "Content-Type",
      "Content-Length",
      "Content-Range",
      "Accept-Ranges",
      "ETag",
      "Cache-Control"
    ]

    max_age_seconds = 3600
  }

  depends_on = [
    google_project_service.services
  ]
}
#Bucket for uploads 
resource "google_storage_bucket" "uploads_private" {
  name                        = "${var.project_id}-uploads-private"
  location                    = var.region
  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"

  versioning {
    enabled = true
  }

  lifecycle_rule {
    condition {
      age = 30
      matches_prefix = [
        "tmp/",
        "imports/tmp/"
      ]
    }

    action {
      type = "Delete"
    }
  }

  depends_on = [
    google_project_service.services
  ]
}