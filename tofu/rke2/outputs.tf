output "rke2_server_ip" {
  description = "The IP address of the RKE2 server VM."
  value       = proxmox_vm_qemu.rke2_server.default_ipv4_address
}
