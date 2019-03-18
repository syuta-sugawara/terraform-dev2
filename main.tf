## terraformのバージョン要求
terraform {
  required_version = "0.11.13"
}

provider "google" {
  credentials = "${file("account.json")}"
  project     = "${var.project-name}"
  region      = "asia-northeast1"#
  zone        = "asia-northeast1-c"#
  version = "~> 2.2.0"
}


#management of enabled api
#resource "google_project_services" "project" {
#  project = "ca-rpa-dev"
#  services   = ["cloudresourcemanager.googleapis.com",
#                "container.googleapis.com",
#                "cloudbuild.googleapis.com", 
#                "sourcerepo.googleapis.com",
#                "containeranalysis.googleapis.com", 
#                "compute.googleapis.com"
#               ]
#}


# add permission to cloudbuild
resource "google_project_iam_binding" "for-creating-container" {
  project ="${var.project-name}"
  role    = "roles/container.developer"

  members = [
    "serviceAccount:619262707437@cloudbuild.gserviceaccount.com",
  ]
}

# add permission to cloudbuild
resource "google_project_iam_binding" "for-writting-source-codes" {
  project = "${var.project-name}"
  role    = "roles/source.writer"

  members = [
    "serviceAccount:619262707437@cloudbuild.gserviceaccount.com",
  ]
}


resource "google_sourcerepo_repository" "apprepo-dev" {
  name = "terraform-app1-repo-dev"
}

resource "google_sourcerepo_repository" "envrepo-dev" {
  name = "terraform-env-repo-dev"
}

resource "google_cloudbuild_trigger" "ci-trigger" {
  trigger_template {
    branch_name = "master"
    repo_name   = "terraform-app1-repo-dev"
  }

  substitutions = {}
  

  filename = "cloudbuild.yaml"
}

resource "google_cloudbuild_trigger" "cd-trigger" {
  trigger_template {
    branch_name = "dev"
    repo_name   = "terraform-env-repo-dev"
  }
  included_files = ["manifests/*"]

  filename = "cloudbuild.yaml"
}

resource "google_container_cluster" "primary" {
  name   = "rpa-dev-cluster"
  region = "asia-northeast1"

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count = 1
  network = "${google_compute_network.terraform-network-dev.self_link}"
  subnetwork                =  "${google_compute_subnetwork.terrform-subnet1-dev.self_link}"
  private_cluster_config = {
      enable_private_nodes    = true,
      master_ipv4_cidr_block= "172.16.0.0/28"
  }

  ip_allocation_policy {
    use_ip_aliases = true
  }

 master_authorized_networks_config {
    cidr_blocks = [
      { cidr_block = "0.0.0.0/0", display_name = "all" },
    
    ]
    }
  # Setting an empty username and password explicitly disables basic auth
  # Setting for k8s master 
  master_auth {
    username = ""
    password = ""
  }

  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }

}

#for production, we must not use preemptible instances
resource "google_container_node_pool" "primary_preemptible_nodes" {
  name       = "rpa-dev-node-pool"
  region     = "asia-northeast1"
  cluster    = "${google_container_cluster.primary.name}"
  node_count = 1

  node_config {
    
    preemptible  = true
    machine_type = "n1-standard-1"

    oauth_scopes = [
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }
}

# The following outputs allow authentication and connectivity to the GKE Cluster
# by using certificate-based authentication.
output "client_certificate" {
  value = "${google_container_cluster.primary.master_auth.0.client_certificate}"
}

output "client_key" {
  value = "${google_container_cluster.primary.master_auth.0.client_key}"
}

output "cluster_ca_certificate" {
  value = "${google_container_cluster.primary.master_auth.0.cluster_ca_certificate}"
}
