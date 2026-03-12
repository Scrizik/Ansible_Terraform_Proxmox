output "web_server_ip" {
  description = "IP du serveur web (dynamique depuis Proxmox)"
  value       = proxmox_vm_qemu.web_server.default_ipv4_address
}

output "db_server_ip" {
  description = "IP du serveur DB (dynamique depuis Proxmox)"
  value       = proxmox_vm_qemu.db_server.default_ipv4_address
}

output "all_vms" {
  description = "Toutes les VMs créées"
  value = {
    web = proxmox_vm_qemu.web_server.default_ipv4_address
    db  = proxmox_vm_qemu.db_server.default_ipv4_address
  }
}
