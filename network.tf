
resource "google_compute_network" "terraform-network-dev" {
  name = "terraform-network-dev"
}

resource "google_compute_subnetwork" "terrform-subnet1-dev" {
  name          = "terrform-subnet1-dev"
  ip_cidr_range = "192.168.10.0/24"
  network       = "${google_compute_network.terraform-network-dev.name}"
  region        ="${local.region}"
}

resource "google_compute_router" "terraform-router-dev" {
  name    = "terraform-router-dev"
  region  = "${google_compute_subnetwork.terrform-subnet1-dev.region}"
  network = "${google_compute_network.terraform-network-dev.name}"
}

resource "google_compute_router_nat" "terraform-nat" {
  name                               = "terraform-nat"
  router                             = "${google_compute_router.terraform-router-dev.name}"
  region                             = "${local.region}"
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}