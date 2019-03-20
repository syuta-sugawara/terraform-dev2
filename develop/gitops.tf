
  resource "google_sourcerepo_repository" "apprepo-dev" {
    count = "${ var.numberOfApp }"
    name = "terraform-app${count.index}-repo-dev"
}

resource "google_sourcerepo_repository" "envrepo-dev" {
  name = "${local.env-repo-name}"
}

resource "google_cloudbuild_trigger" "ci-trigger" {
  count = "${ var.numberOfApp }"
  trigger_template {
    branch_name = "master"
    repo_name   = "terraform-app${count.index}-repo-dev"
  }

  substitutions = {
    _MANIFESTS_REPO_NAME =  "${local.env-repo-name}"
    }
  

  filename = "cloudbuild.yaml"
}

resource "google_cloudbuild_trigger" "cd-trigger" {
  trigger_template {
    branch_name = "dev"
    repo_name   = "${local.env-repo-name}"
  }
  included_files = ["manifests/*"]

  substitutions = {
     _CLUSTER = "${google_container_cluster.primary.name}"
     _REGION = "${google_container_cluster.primary.region}"
    }

  filename = "cloudbuild.yaml"
}
