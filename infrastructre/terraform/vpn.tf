resource "google_compute_ha_vpn_gateway" "main" {
  name    = "immutible-cloud"
  region  = var.region
  network = google_compute_network.main_vpc.id
}

//khi dung HA vpn tren google cloud buoc phai tao peer gateway co 2 int
resource "google_compute_external_vpn_gateway" "pfsense" {
  name            = "pfsenseha1"
  redundancy_type = "TWO_IPS_REDUNDANCY"
  description     = "pfSense HA on-premises gateway"

  interface {
    id         = 0
    ip_address = "123.21.249.22"  
  }

  interface {
    id         = 1
    ip_address = "123.21.249.22"  
  }
}

resource "google_compute_vpn_tunnel" "tunnel1" {
  name                            = "pfsense1"
  region                          = var.region
  vpn_gateway                     = google_compute_ha_vpn_gateway.main.id
  vpn_gateway_interface           = 0
  peer_external_gateway           = google_compute_external_vpn_gateway.pfsense.id
  peer_external_gateway_interface = 0
  shared_secret                   = var.vpn_shared_secret
  router                          = google_compute_router.router.id
  ike_version                     = 2
}

resource "google_compute_vpn_tunnel" "tunnel2" {
  name                            = "pfsense2"
  region                          = var.region
  vpn_gateway                     = google_compute_ha_vpn_gateway.main.id
  vpn_gateway_interface           = 1
  peer_external_gateway           = google_compute_external_vpn_gateway.pfsense.id
  peer_external_gateway_interface = 0
  shared_secret                   = var.vpn_shared_secret
  router                          = google_compute_router.router.id
  ike_version                     = 2
}

//tao int de giao tiep voi int onpremis
resource "google_compute_router_interface" "tunnel1_interface" {
  name       = "tunnel1-interface"
  router     = google_compute_router.router.name
  region     = var.region
  ip_range   = "169.254.128.41/30"
  vpn_tunnel = google_compute_vpn_tunnel.tunnel1.name
}

resource "google_compute_router_interface" "tunnel2_interface" {
  name       = "tunnel2-interface"
  router     = google_compute_router.router.name
  region     = var.region
  ip_range   = "169.254.151.181/30"
  vpn_tunnel = google_compute_vpn_tunnel.tunnel2.name
}

resource "google_compute_router_peer" "tunnel1_peer" {
  name                      = "bgp-pfsense-1"
  router                    = google_compute_router.router.name
  region                    = var.region
  peer_ip_address           = "169.254.128.42"
  peer_asn                  = 65002
  interface                 = google_compute_router_interface.tunnel1_interface.name
  advertised_route_priority = 100
}

resource "google_compute_router_peer" "tunnel2_peer" {
  name                      = "bgp-pfsense-2"
  router                    = google_compute_router.router.name
  region                    = var.region
  peer_ip_address           = "169.254.151.182"
  peer_asn                  = 65002
  interface                 = google_compute_router_interface.tunnel2_interface.name
  advertised_route_priority = 100
}
