# output "instance_name"  { value = google_compute_instance.vm.name }
# output "instance_id"    { value = google_compute_instance.vm.instance_id }
# output "public_ip"      { value = google_compute_instance.vm.network_interface[0].access_config[0].nat_ip }
# output "internal_ip"    { value = google_compute_instance.vm.network_interface[0].network_ip }
# output "zone"           { value = google_compute_instance.vm.zone }
# output "machine_type"   { value = google_compute_instance.vm.machine_type }
# output "image_used"     { value = data.google_compute_image.os_image.self_link }
# output "ssh_command" {
#   value = "gcloud compute ssh ${google_compute_instance.vm.name} --zone=${google_compute_instance.vm.zone}"
# }
# output "mig_self_link"      { value = google_compute_instance_group_manager.mig.self_link }
# output "mig_instance_group" { value = google_compute_instance_group_manager.mig.instance_group }
# output "template_id"        { value = google_compute_instance_template.tmpl.id }
# output "autoscaler_name"    { value = google_compute_autoscaler.asg.name }
# output "load_balancer_ip" {
#   description = "Truy cap website tai dia chi nay"
#   value       = google_compute_global_address.lb_ip.address
# }

# output "mig_instance_group" {
#   description = "Self link cua MIG instance group"
#   value       = google_compute_instance_group_manager.mig.instance_group
# }
output "instance_ip" {
  value = google_compute_instance.frontend.network_interface.0.access_config.0.nat_ip
}

# output "vpn_gateway_ip_0" {
#   description = "IP VPN interface 0 — điền vào pfSense con1 Remote"
#   value       = google_compute_ha_vpn_gateway.main.vpn_interfaces[0].ip_address
# }

# output "vpn_gateway_ip_1" {
#   description = "IP VPN interface 1 — điền vào pfSense con2 Remote"
#   value       = google_compute_ha_vpn_gateway.main.vpn_interfaces[1].ip_address
# }

