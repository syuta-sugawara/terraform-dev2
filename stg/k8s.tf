
resource "google_container_cluster" "primary" {
  name   = "${var.cluster-name}"
  region = "${local.region}"

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count = 1
  network = "${google_compute_network.terraform-network-stg.self_link}"
  subnetwork                =  "${google_compute_subnetwork.terrform-subnet1-stg.self_link}"
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
  name       = "rpa-stg-node-pool"
  region     =  "${local.region}"
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
