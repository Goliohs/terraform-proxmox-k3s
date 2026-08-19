# Example: k3s Master Nodes (3-node HA cluster)

terraform {
  required_version = ">= 1.6.0"

  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = ">= 0.60.0"
    }
  }
}

provider "proxmox" {
  pm_api_url          = var.proxmox_api_url
  pm_api_token_id     = var.proxmox_api_token_id
  pm_api_token_secret = var.proxmox_api_token_secret
  pm_tls_insecure     = var.proxmox_insecure
}

# Shared k3s token for cluster
resource "random_password" "k3s_token" {
  length  = 32
  special = false
  keepers = {
    cluster = "k3s-production"
  }
}

# Master 1 (bootstrap node)
module "master_1" {
  source = "../../"

  create              = true
  vm_id               = 100
  name                = "k3s-master-1"
  target_node         = "proxmox-node-1"
  role                = "master"
  cpu_cores           = 8
  memory_mb           = 32768
  disk_size_gb        = 100
  storage             = "local-lvm"

  k3s_version         = "v1.29.6+k3s1"
  k3s_token           = random_password.k3s_token.result
  k3s_master_ip       = "10.10.20.110"
  node_ip             = "10.10.20.110"

  network_interfaces = [
    { bridge = "vmbr0", vlan = 20 },  # k8s-mgmt
    { bridge = "vmbr0", vlan = 30 },  # ceph-public
    { bridge = "vmbr0", vlan = 40 },  # ceph-cluster
    { bridge = "vmbr0", vlan = 50 },  # storage
  ]

  ssh_keys             = var.ssh_keys
  ci_user              = "ubuntu"
  dns_servers          = ["10.10.10.1", "1.1.1.1"]
  search_domain        = "k3s.local"
  ssh_private_key_path = "~/.ssh/id_ed25519"
}

# Master 2
module "master_2" {
  source = "../../"

  create              = true
  vm_id               = 101
  name                = "k3s-master-2"
  target_node         = "proxmox-node-2"
  role                = "master"
  cpu_cores           = 8
  memory_mb           = 32768
  disk_size_gb        = 100
  storage             = "local-lvm"

  k3s_version         = "v1.29.6+k3s1"
  k3s_token           = random_password.k3s_token.result
  k3s_master_ip       = "10.10.20.110"
  node_ip             = "10.10.20.111"

  network_interfaces = [
    { bridge = "vmbr0", vlan = 20 },
    { bridge = "vmbr0", vlan = 30 },
    { bridge = "vmbr0", vlan = 40 },
    { bridge = "vmbr0", vlan = 50 },
  ]

  ssh_keys             = var.ssh_keys
  ci_user              = "ubuntu"
  dns_servers          = ["10.10.10.1", "1.1.1.1"]
  search_domain        = "k3s.local"
  ssh_private_key_path = "~/.ssh/id_ed25519"
}

# Master 3
module "master_3" {
  source = "../../"

  create              = true
  vm_id               = 102
  name                = "k3s-master-3"
  target_node         = "proxmox-node-3"
  role                = "master"
  cpu_cores           = 8
  memory_mb           = 32768
  disk_size_gb        = 100
  storage             = "local-lvm"

  k3s_version         = "v1.29.6+k3s1"
  k3s_token           = random_password.k3s_token.result
  k3s_master_ip       = "10.10.20.110"
  node_ip             = "10.10.20.112"

  network_interfaces = [
    { bridge = "vmbr0", vlan = 20 },
    { bridge = "vmbr0", vlan = 30 },
    { bridge = "vmbr0", vlan = 40 },
    { bridge = "vmbr0", vlan = 50 },
  ]

  ssh_keys             = var.ssh_keys
  ci_user              = "ubuntu"
  dns_servers          = ["10.10.10.1", "1.1.1.1"]
  search_domain        = "k3s.local"
  ssh_private_key_path = "~/.ssh/id_ed25519"
}

output "master_1_ip" {
  value = module.master_1.vm_ip_mgmt
}

output "master_2_ip" {
  value = module.master_2.vm_ip_mgmt
}

output "master_3_ip" {
  value = module.master_3.vm_ip_mgmt
}

output "k3s_token" {
  value     = random_password.k3s_token.result
  sensitive = true
}

output "kubeconfig_1" {
  value     = module.master_1.kubeconfig_command
  sensitive = true
}