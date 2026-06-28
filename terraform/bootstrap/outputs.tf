output "terraform_state_bucket" {
  value = google_storage_bucket.terraform_state.name
}

output "github_actions_gsa_email" {
  value = google_service_account.github_actions.email
}

output "github_workload_identity_provider" {
  value = google_iam_workload_identity_pool_provider.github.name
}
