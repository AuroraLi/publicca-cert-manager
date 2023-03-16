resource "google_service_account" "dns_service_account" {
  account_id   = "dns01-solver"
  display_name = "dns01-solver"
  project = local.project_id
}

resource "google_project_iam_member" "dns" {
  project = var.dns_project
  role    = "roles/dns.admin"
  member  = "serviceAccount:${google_service_account.dns_service_account.email}"
}


resource "google_service_account_iam_binding" "admin-account-iam" {
  service_account_id = google_service_account.dns_service_account.name
  role               = "roles/iam.workloadIdentityUser"
  members = [
    "serviceAccount:${local.project_id}.svc.id.goog[cert-manager/cert-manager]",
  ]
}