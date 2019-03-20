
resource "google_compute_network" "terraform-network-stg" {
  name = "terraform-network-stg"
}

resource "google_compute_subnetwork" "terrform-subnet1-stg" {
  name          = "terrform-subnet1-stg"
  ip_cidr_range = "192.168.10.0/24"
  network       = "${google_compute_network.terraform-network-stg.name}"
  region        ="${local.region}"
}

resource "google_compute_router" "terraform-router-stg" {
  name    = "terraform-router-stg"
  region  = "${google_compute_subnetwork.terrform-subnet1-stg.region}"
  network = "${google_compute_network.terraform-network-stg.name}"
}

resource "google_compute_router_nat" "terraform-nat" {
  name                               = "terraform-nat"
  router                             = "${google_compute_router.terraform-router-stg.name}"
  region                             = "${local.region}"
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}