resource "google_service_account" "cm_service_account" {
  account_id   = "cm-reader"
  display_name = "reading and editing certificate "
  project = local.project_id
}

resource "google_project_iam_member" "cm" {
  project = local.project_id
  role    = "roles/certificatemanager.editor"
  member  = "serviceAccount:${google_service_account.cm_service_account.email}"
}


resource "google_service_account_iam_binding" "cm-account-iam" {
  service_account_id = google_service_account.cm_service_account.name
  role               = "roles/iam.workloadIdentityUser"
  members = [
    "serviceAccount:${local.project_id}.svc.id.goog[cert-manager/cert-manager-sync]",
  ]
}