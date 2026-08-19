resource "proxmox_vm_qemu" "vm" {
  count = var.create ? 1 : 0

  vm_id       = var.vm_id
  name        = var.name
  target_node = var.target_node
  clone       = var.iso_image == "" ? null : var.iso_image
  full_clone  = var.iso_image == "" ? null : true

  cores   = var.cpu_cores
  sockets = 1
  memory  = var.memory_mb

  cpu_type = var.cpu_type
  numa     = var.numa
  machine  = var.machine
  bios     = var.bios
  efi_disk = var.efi_disk

  os_type = "cloud-init"

  agent  = var.agent ? 1 : 0
  tablet = var.tablet ? 1 : 0

  onboot = var.onboot

  tags = join(",", var.tags)

  disk {
    id        = 0
    type      = "scsi"
    storage   = var.storage
    size      = "${var.disk_size_gb}G"
    iothread  = 1
    discard   = "on"
    ssd       = 1
    backup    = 1
    replicate = 0
  }

  dynamic "network" {
    for_each = var.network_interfaces
    content {
      bridge   = network.value.bridge
      model    = network.value.model
      vlan     = network.value.vlan
      mac      = network.value.mac
      firewall = network.value.firewall ? 1 : 0
    }
  }

  dynamic "cloud_init" {
    for_each = var.cloud_init_config != null ? [var.cloud_init_config] : []
    content {
      user         = var.ci_user
      password     = var.ci_password_hash != "" ? var.ci_password_hash : null
      ssh_keys     = var.ssh_keys
      ipconfig0    = cloud_init.value.ipconfig0
      ipconfig1    = cloud_init.value.ipconfig1
      dns          = cloud_init.value.dns
      domain       = cloud_init.value.domain
      nameserver   = join(" ", var.dns_servers)
      searchdomain = var.search_domain
    }
  }

  lifecycle {
    ignore_changes = [
      disk[0].size,
      network,
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
    vm_id       = proxmox_vm_qemu.vm[0].vm_id
    k3s_version = var.k3s_version
    k3s_token   = var.k3s_token
  }

  connection {
    type        = "ssh"
    host        = var.role == "master" ? var.k3s_master_ip : var.k3s_master_ip
    user        = var.ci_user
    private_key = file(var.ssh_private_key_path)
    timeout     = "15m"
  }

  provisioner "remote-exec" {
    inline = [
      "curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=${var.k3s_version} K3S_TOKEN=${var.k3s_token} sh -s - ${var.role == "master" ? "server --cluster-init --disable=traefik --disable=servicelb --flannel-backend=none --disable-network-policy --node-ip=${var.node_ip} --node-external-ip=${var.node_ip} --tls-san=${var.node_ip} --tls-san=${var.name} --tls-san=k3s.${var.search_domain} --write-kubeconfig-mode=644" : "agent --server https://${var.k3s_master_ip}:6443 --node-ip=${var.node_ip} --node-external-ip=${var.node_ip}"}",
      "mkdir -p /home/${var.ci_user}/.kube",
      "sudo cp /etc/rancher/k3s/k3s.yaml /home/${var.ci_user}/.kube/config",
      "sudo chown ${var.ci_user}:${var.ci_user} /home/${var.ci_user}/.kube/config",
      "echo 'export KUBECONFIG=/home/${var.ci_user}/.kube/config' >> /home/${var.ci_user}/.bashrc",
    ]
  }
}