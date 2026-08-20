resource "proxmox_virtual_environment_vm" "vm" {
  count = var.create ? 1 : 0

  vm_id     = var.vm_id
  name      = var.name
  node_name = var.target_node
  tags      = var.tags

  bios        = var.bios
  machine     = var.machine
  on_boot     = var.on_boot
  started     = true
  template    = false
  protection  = false
  description = "Managed by terraform-proxmox-k3s"

  cpu {
    cores   = var.cpu_cores
    sockets = 1
    type    = var.cpu_type
  }

  memory {
    dedicated = var.memory_mb
  }

  disk {
    interface    = "scsi"
    datastore_id = var.storage
    size         = "${var.disk_size_gb}G"
    iothread     = true
    discard      = "on"
    ssd          = true
    backup       = true
  }

  network_device {
    bridge      = var.network_interfaces[0].bridge
    model       = var.network_interfaces[0].model
    vlan_id     = var.network_interfaces[0].vlan
    mac_address = var.network_interfaces[0].mac
    firewall    = var.network_interfaces[0].firewall
  }

  initialization {
    interface    = "ide2"
    datastore_id = var.storage
    dns {
      domain  = var.search_domain
      servers = var.dns_servers
    }
    ip_config {
      ipv4 {
        address = var.node_ip != "" ? "${var.node_ip}/24" : null
        gateway = null
      }
    }
    user_account {
      username = var.ci_user
      password = var.ci_password_hash != "" ? var.ci_password_hash : null
      keys     = var.ssh_keys
    }
  }

  agent {
    enabled = var.agent
  }

  efi_disk {
    type         = "2m"
    datastore_id = var.storage
  }

  tablet_device = var.tablet_device

  lifecycle {
    ignore_changes = [
      disk[0].size,
      network_device,
    ]
  }
}

resource "random_password" "vm_password" {
  count            = var.create && var.generate_password ? 1 : 0
  length           = 32
  special          = true
  override_special = "/@#$%&*()-_=+[]{}|:;<>,.?"
  keepers = {
    vm_id = var.vm_id
  }
}

resource "null_resource" "k3s_install" {
  count = var.create && var.install_k3s ? 1 : 0

  triggers = {
    vm_id       = proxmox_virtual_environment_vm.vm[0].vm_id
    k3s_version = var.k3s_version
    k3s_token   = var.k3s_token
  }

  connection {
    type        = "ssh"
    host        = var.k3s_master_ip
    user        = var.ci_user
    private_key = file(var.ssh_private_key_path)
    timeout     = "15m"
  }

  provisioner "remote-exec" {
    inline = [
      format("curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=%s K3S_TOKEN=%s sh -s - %s",
        var.k3s_version,
        var.k3s_token,
        var.role == "master"
        ? "server --cluster-init --disable=traefik --disable=servicelb --flannel-backend=none --disable-network-policy --node-ip=${var.node_ip} --node-external-ip=${var.node_ip} --tls-san=${var.node_ip} --tls-san=${var.name} --tls-san=k3s.${var.search_domain} --write-kubeconfig-mode=644"
        : "agent --server https://${var.k3s_master_ip}:6443 --node-ip=${var.node_ip} --node-external-ip=${var.node_ip}"
      ),
      "mkdir -p /home/${var.ci_user}/.kube",
      "sudo cp /etc/rancher/k3s/k3s.yaml /home/${var.ci_user}/.kube/config",
      "sudo chown ${var.ci_user}:${var.ci_user} /home/${var.ci_user}/.kube/config",
      "echo 'export KUBECONFIG=/home/${var.ci_user}/.kube/config' >> /home/${var.ci_user}/.bashrc",
    ]
  }
}

output "vm_id" {
  description = "VM ID in Proxmox"
  value       = var.create ? proxmox_virtual_environment_vm.vm[0].vm_id : null
}

output "vm_name" {
  description = "VM name"
  value       = var.create ? proxmox_virtual_environment_vm.vm[0].name : null
}

output "vm_target_node" {
  description = "Proxmox node where VM is deployed"
  value       = var.create ? proxmox_virtual_environment_vm.vm[0].node_name : null
}

output "vm_ip_mgmt" {
  description = "Management/k8s API IP"
  value       = var.create ? proxmox_virtual_environment_vm.vm[0].ipv4_addresses[0] : null
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
  value       = var.role == "master" ? "ssh ${var.ci_user}@${proxmox_virtual_environment_vm.vm[0].ipv4_addresses[0]} 'cat /etc/rancher/k3s/k3s.yaml'" : null
}