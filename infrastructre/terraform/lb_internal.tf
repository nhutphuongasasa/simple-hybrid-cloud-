# //static private ip
# resource "google_compute_address" "internal_lb_ip" {
#   name         = "${var.instance_name}-internal-ip"
#   subnetwork   = google_compute_subnetwork.main_subnet.id
#   address_type = "INTERNAL"
#   address      = "192.168.1.100"
#   region       = var.region
# }

# resource "google_compute_global_forwarding_rule" "forwarding_rule" {
#   name                  = "${var.instance_name}-forwarding-rule"
#   target                = google_compute_target_http_proxy.http_proxy.id
#   port_range            = "80"
#   load_balancing_scheme = "INTERNAL_MANAGED"
#   ip_address            = google_compute_address.internal_lb_ip.address
# }

# resource "google_compute_target_http_proxy" "http_proxy" {
#   name    = "${var.instance_name}-http-proxy"
#   url_map = google_compute_url_map.url_map.id
# }

# resource "google_compute_url_map" "url_map" {
#   name            = "${var.instance_name}-url-map"
#   default_service = google_compute_backend_service.backend.id

#   host_rule {
#     hosts        = ["*"]
#     path_matcher = "my-paths" //ten bo quy tac path matcher phia duoi
#   }
#   path_matcher {
#     name            = "my-paths"
#     default_service = google_compute_backend_service.backend.id
#     path_rule {
#       paths   = ["/api", "/api/*"]
#       service = google_compute_backend_service.backend.id
#     }
#   }
# }

# resource "google_compute_backend_service" "backend" {
#   name                  = "${var.instance_name}-backend"
#   port_name             = "http"
#   protocol              = "HTTP"
#   load_balancing_scheme = "EXTERNAL"
#   timeout_sec           = 30

#   backend {
#     group           = google_compute_instance_group_manager.mig.instance_group //gan bo quy tac vao instance group
#     balancing_mode  = "UTILIZATION"
#     capacity_scaler = 1.0
#   }

#   health_checks = [google_compute_health_check.hc.id]
#   depends_on = [google_compute_health_check.hc]
# }




