output "vm_id" {
  description = "VM ID in Proxmox"
  value       = var.create ? proxmox_vm_qemu.vm[0].vm_id : null
}

output "vm_name" {
  description = "VM name"
  value       = var.create ? proxmox_vm_qemu.vm[0].name : null
}

output "vm_target_node" {
  description = "Proxmox node where VM is deployed"
  value       = var.create ? proxmox_vm_qemu.vm[0].target_node : null
}

output "vm_ip_mgmt" {
  description = "Management/k8s API IP (from cloud-init ipconfig0)"
  value       = var.create ? proxmox_vm_qemu.vm[0].ipconfig0 : null
}

output "vm_ip_ceph_public" {
  description = "Ceph public/client IP (VLAN 30)"
  value       = var.create ? lookup(proxmox_vm_qemu.vm[0], "ipconfig1", "") : null
}

output "k3s_token" {
  description = "k3s cluster token"
  value       = var.k3s_token
  sensitive   = true
}

output "role" {
  description = "Node role"
  value       = var.role
}

output "generated_password" {
  description = "Generated VM password (if enabled)"
  value       = var.create && var.generate_password ? random_password.vm_password[0].result : null
  sensitive   = true
}

output "kubeconfig_command" {
  description = "Command to fetch kubeconfig from the master node"
  value       = var.role == "master" ? "ssh ${var.ci_user}@${proxmox_vm_qemu.vm[0].ipconfig0} 'cat /etc/rancher/k3s/k3s.yaml'" : null
}