output "docker_registry_server_ip" {
  description = "The IP address of the RKE2 server VM."
  value       = proxmox_virtual_environment_vm.docker_registry.ipv4_addresses
}
