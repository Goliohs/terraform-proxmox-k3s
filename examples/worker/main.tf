# Example: k3s Worker Nodes

terraform {
  required_version = ">= 1.6.0"

  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.111"
    }
  }
}

provider "proxmox" {
  endpoint   = var.proxmox_api_url
  insecure   = var.proxmox_insecure
  api_token  = var.proxmox_api_token
}

# Worker 1
module "worker_1" {
  source = "../../"

  create              = true
  vm_id               = 200
  name                = "k3s-worker-1"
  target_node         = "proxmox-node-1"
  role                = "worker"
  cpu_cores           = 16
  memory_mb           = 65536
  disk_size_gb        = 200
  storage             = "local-lvm"

  k3s_version         = "v1.29.6+k3s1"
  k3s_token           = var.k3s_token
  k3s_master_ip       = var.k3s_master_ip
  node_ip             = "10.10.20.120"

  network_interfaces = [
    { bridge = "vmbr0", vlan = 20 }, # k8s-mgmt
    { bridge = "vmbr0", vlan = 30 }, # ceph-public
    { bridge = "vmbr0", vlan = 40 }, # ceph-cluster
    { bridge = "vmbr0", vlan = 50 }, # storage
    { bridge = "vmbr0", vlan = 60 }, # gpu (optional)
  ]

  ssh_keys             = var.ssh_keys
  ci_user              = "ubuntu"
  dns_servers          = ["10.10.10.1", "1.1.1.1"]
  search_domain        = "k3s.local"
  ssh_private_key_path = "~/.ssh/id_ed25519"
}

# Worker 2
module "worker_2" {
  source = "../../"

  create       = true
  vm_id        = 201
  name         = "k3s-worker-2"
  target_node  = "proxmox-node-2"
  role         = "worker"
  cpu_cores    = 16
  memory_mb    = 65536
  disk_size_gb = 200
  storage      = "local-lvm"

  k3s_version   = "v1.29.6+k3s1"
  k3s_token     = var.k3s_token
  k3s_master_ip = var.k3s_master_ip
  node_ip       = "10.10.20.121"

  network_interfaces = [
    { bridge = "vmbr0", vlan = 20 },
    { bridge = "vmbr0", vlan = 30 },
    { bridge = "vmbr0", vlan = 40 },
    { bridge = "vmbr0", vlan = 50 },
    { bridge = "vmbr0", vlan = 60 },
  ]

  ssh_keys             = var.ssh_keys
  ci_user              = "ubuntu"
  dns_servers          = ["10.10.10.1", "1.1.1.1"]
  search_domain        = "k3s.local"
  ssh_private_key_path = "~/.ssh/id_ed25519"
}

# GPU Worker (for AI/ML workloads)
module "gpu_worker" {
  source = "../../"

  create       = true
  vm_id        = 202
  name         = "k3s-gpu-worker-1"
  target_node  = "proxmox-gpu-node"
  role         = "worker"
  cpu_cores    = 32
  memory_mb    = 131072
  disk_size_gb = 500
  storage      = "local-lvm"

  k3s_version   = "v1.29.6+k3s1"
  k3s_token     = var.k3s_token
  k3s_master_ip = var.k3s_master_ip
  node_ip       = "10.10.20.130"

  network_interfaces = [
    { bridge = "vmbr0", vlan = 20 },
    { bridge = "vmbr0", vlan = 30 },
    { bridge = "vmbr0", vlan = 40 },
    { bridge = "vmbr0", vlan = 50 },
    { bridge = "vmbr0", vlan = 60 }, # GPU VLAN
  ]

  ssh_keys             = var.ssh_keys
  ci_user              = "ubuntu"
  dns_servers          = ["10.10.10.1", "1.1.1.1"]
  search_domain        = "k3s.local"
  ssh_private_key_path = "~/.ssh/id_ed25519"
}

output "worker_1_ip" {
  value = module.worker_1.vm_ip_mgmt
}

output "worker_2_ip" {
  value = module.worker_2.vm_ip_mgmt
}

output "gpu_worker_ip" {
  value = module.gpu_worker.vm_ip_mgmt
}