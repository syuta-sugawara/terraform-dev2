
  resource "google_sourcerepo_repository" "apprepo-stg" {
    count = "${ var.numberOfApp }"
    name = "terraform-app${count.index}-repo-stg"
}

resource "google_sourcerepo_repository" "envrepo-stg" {
  name = "${var.env-repo}"
}

resource "google_cloudbuild_trigger" "ci-trigger" {
  count = "${ var.numberOfApp }"
  trigger_template {
    branch_name = "master"
    repo_name   = "terraform-app${count.index}-repo-stg"
  }

  substitutions = {
    _MANIFESTS_REPO_NAME =  "${var.env-repo}"
    }
  

  filename = "cloudbuild.yaml"
}

resource "google_cloudbuild_trigger" "cd-trigger" {
  trigger_template {
    branch_name = "dev"
    repo_name   = "${var.env-repo}"
  }
  included_files = ["manifests/*"]

  substitutions = {
     _CLUSTER = "${google_container_cluster.primary.name}"
     _REGION = "${google_container_cluster.primary.region}"
    }

  filename = "cloudbuild.yaml"
}
