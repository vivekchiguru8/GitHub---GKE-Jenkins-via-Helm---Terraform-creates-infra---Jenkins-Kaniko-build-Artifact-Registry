terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
  }
}

provider "google" {
  project = "project-10094705-9153-43d5-bb8"
  region  = "asia-south1"
}

resource "google_project_service" "apis" {
  for_each = toset([
    "container.googleapis.com",
    "artifactregistry.googleapis.com",
    "iam.googleapis.com",
    "apigateway.googleapis.com",
    "servicecontrol.googleapis.com"
  ])
  service = each.value
}

resource "google_artifact_registry_repository" "my_app_repo" {
  location      = "asia-south1"
  repository_id = "my-app-repo-v2"
  format        = "DOCKER"
  description   = "Repo for Go app"
  depends_on    = [google_project_service.apis]
}

resource "google_container_cluster" "primary" {
  name               = "my-go-cluster-v2"
  location           = "asia-south1-a"
  initial_node_count = 2
  deletion_protection = false

  workload_identity_config {
    workload_pool = "project-10094705-9153-43d5-bb8.svc.id.goog"
  }

  depends_on = [google_project_service.apis]
}

# GSA for Jenkins - v2
resource "google_service_account" "jenkins_gsa" {
  account_id   = "jenkins-workload-sa-v2"
  display_name = "Jenkins Workload Identity SA v2"
}

# Give permissions to GSA
resource "google_project_iam_member" "jenkins_roles" {
  for_each = toset([
    "roles/container.admin",
    "roles/artifactregistry.admin",
    "roles/storage.admin",
    "roles/iam.serviceAccountUser"
  ])
  project = "project-10094705-9153-43d5-bb8"
  role    = each.value
  member  = "serviceAccount:${google_service_account.jenkins_gsa.email}"
}

# Allow KSA to impersonate GSA
resource "google_service_account_iam_member" "wi_binding" {
  service_account_id = google_service_account.jenkins_gsa.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:project-10094705-9153-43d5-bb8.svc.id.goog[jenkins/jenkins]"
}