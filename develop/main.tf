## terraformのバージョン要求
terraform {
  required_version = "0.11.13"
}

provider "google" {
  credentials = "${file("account.json")}"
  project     = "${var.project-name}"
  version = "~> 2.2.0"
}



data "google_project" "project" {}

# add permission to cloudbuild
resource "google_project_iam_binding" "for-creating-container" {
  project ="${var.project-name}"
  role    = "roles/container.developer"

  members = [
    "serviceAccount:${data.google_project.project.number}@cloudbuild.gserviceaccount.com",
  ]
}

# add permission to cloudbuild
resource "google_project_iam_binding" "for-writting-source-codes" {
  project = "${var.project-name}"
  role    = "roles/source.writer"

  members = [
    "serviceAccount:${data.google_project.project.number}@cloudbuild.gserviceaccount.com",
  ]
}

