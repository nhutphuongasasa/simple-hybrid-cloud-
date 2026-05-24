resource "google_compute_network" "main_vpc" {
  name                    = "main-vpc"
  auto_create_subnetworks = false 
}

resource "google_compute_subnetwork" "main_subnet" {
  name          = "${var.region}-subnet"
  ip_cidr_range = "192.168.1.0/24"
  region        = var.region
  network       = google_compute_network.main_vpc.id
  
  private_ip_google_access = true 
}

resource "google_compute_router" "router" {
  name    = "main-router"
  region  = var.region
  network = google_compute_network.main_vpc.id

  bgp {
    asn            = 65001
    advertise_mode = "CUSTOM"
    
    advertised_ip_ranges {
      range       = "192.168.1.0/24"
      description = "main-vpc subnet"
    }
  }
}

resource "google_compute_router_nat" "nat" {
  name                               = "main-nat"
  router                             = google_compute_router.router.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}
