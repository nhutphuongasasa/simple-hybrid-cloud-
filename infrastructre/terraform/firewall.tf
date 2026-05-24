
resource "google_compute_firewall" "allow_ssh" {
  name    = "${var.instance_name}-allow-ssh"
  network = google_compute_network.main_vpc.id
  allow { 
    protocol = "tcp"
    ports = ["22"] 
    }
  target_tags   = ["allow-ssh"]
  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "allow_http" {
  name    = "${var.instance_name}-allow-http"
  network = google_compute_network.main_vpc.id
  allow { 
    protocol = "tcp"
   ports = ["80"] 
   }
  target_tags   = ["http-server"]
  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "allow_https" {
  name    = "${var.instance_name}-allow-https"
  network = google_compute_network.main_vpc.id
  allow { 
    protocol = "tcp"
    ports = ["443"] 
    }
  target_tags   = ["web-server"]
  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "allow_lb_health_check" {
  name    = "${var.instance_name}-allow-lb-hc"
  network = google_compute_network.main_vpc.id

  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]
  
  target_tags   = ["web-server"]

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
}

resource "google_compute_firewall" "allow_internal_ping" {
  name    = "allow-internal-icmp"
  network = google_compute_network.main_vpc.id

  allow {
    protocol = "icmp"
  }

  target_tags = ["allow-icmp"]

  source_ranges = [
    "192.168.1.0/24",      
    "192.168.10.0/24",     
    "192.168.175.0/24",    
  ]
}

resource "google_compute_firewall" "allow_only_for_backend" {
  name    = "allow-internal-to-backend"
  network = google_compute_network.main_vpc.id

  allow {
    protocol = "tcp"
    ports    = ["3001"] 
  }

  source_ranges = ["192.168.1.0/24"]

  target_tags = ["backend-node"] 
}

resource "google_compute_firewall" "allow_onprem" {
  name    = "allow-onprem-traffic"
  network = google_compute_network.main_vpc.id

  allow {
    protocol = "all"
  }

  source_ranges = [
    "192.168.175.0/24",
    "192.168.10.0/24",
  ]
}

resource "google_compute_firewall" "allow_bgp" {
  name    = "allow-bgp-from-pfsense"
  network = google_compute_network.main_vpc.id

  allow {
    protocol = "tcp"
    ports    = ["179"]
  }

  source_ranges = [
    "169.254.128.42/32",
    "169.254.151.182/32",
  ]
}
