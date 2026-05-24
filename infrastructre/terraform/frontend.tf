data "google_compute_image" "front_end_image" {
  # family  = frontend-images
  name = "nginx-frontend-v1"
  project = var.project_id
}

data "google_compute_image" "back_end_image" {
  # family  = backend-images
  name = "backend-v1"
  project = var.project_id
}

resource "google_compute_instance" "frontend" {
  name         = var.instance_name_frontend
  machine_type = "e2-medium"
  zone         = var.zone

  tags = ["allow-ssh", "web-server", "http-server"]

  boot_disk {
    initialize_params {
      image = data.google_compute_image.front_end_image.self_link
      size  = 20
      type  = "pd-standard"
    }
  }

  network_interface {
    network    = google_compute_network.main_vpc.id
    subnetwork = google_compute_subnetwork.main_subnet.id

    access_config {
    }
  }

metadata = {
  startup-script = "#!/bin/bash\ncd /opt/app && sudo -u ubuntu docker compose up --build -d\n"
}

  depends_on = [
    google_compute_subnetwork.main_subnet,
    google_compute_firewall.allow_ssh,
    google_compute_firewall.allow_http
  ]
}

resource "google_compute_address" "backend_internal_ip" {
  name         = "backend-static-ip"
  subnetwork   = google_compute_subnetwork.main_subnet.id
  address_type = "INTERNAL"
  region       = var.region 
  address    = "192.168.1.100" 
}

resource "google_compute_instance" "backend" {
  name         = var.instance_name_backend
  machine_type = "e2-medium"
  zone         = var.zone

  tags = ["allow-ssh", "web-server", "http-server", "backend-node", "allow-icmp", "allow-onprem-traffic"]

  boot_disk {
    initialize_params {
      image = data.google_compute_image.back_end_image.self_link
      size  = 20
      type  = "pd-standard"
    }
  }

  network_interface {
    network    = google_compute_network.main_vpc.id
    subnetwork = google_compute_subnetwork.main_subnet.id
    network_ip = google_compute_address.backend_internal_ip.address
    # access_config {
    # }
  }

metadata = {
  startup-script = "#!/bin/bash\ncd /opt/app && sudo -u ubuntu docker compose up --build -d\n"
}

  depends_on = [
    google_compute_subnetwork.main_subnet,
    google_compute_firewall.allow_ssh,
    google_compute_firewall.allow_http
  ]
}

