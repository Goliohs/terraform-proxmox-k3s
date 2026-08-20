variable "proxmox_api_url" {
  description = "Proxmox API URL (e.g., https://proxmox.example.com:8006/api2/json)"
  type        = string
}

variable "proxmox_api_token" {
  description = "Proxmox API token (format: USER@REALM!TOKENID=UUID)"
  type        = string
  sensitive   = true
}

variable "proxmox_insecure" {
  description = "Skip TLS verification"
  type        = bool
  default     = true
}

# VM configuration
variable "create" {
  description = "Whether to create the VM (allows conditional creation)"
  type        = bool
  default     = true
}

variable "vm_id" {
  description = "Unique VM ID in Proxmox (100-999999999)"
  type        = number
  validation {
    condition     = var.vm_id >= 100 && var.vm_id <= 999999999
    error_message = "VM ID must be between 100 and 999999999."
  }
}

variable "name" {
  description = "VM name/hostname (e.g., k3s-master-1, k3s-worker-1)"
  type        = string
  validation {
    condition     = length(var.name) > 0 && length(var.name) <= 63
    error_message = "Name must be 1-63 characters."
  }
}

variable "target_node" {
  description = "Proxmox node to deploy on"
  type        = string
}

variable "role" {
  description = "Node role: 'master' or 'worker'"
  type        = string
  validation {
    condition     = contains(["master", "worker"], var.role)
    error_message = "Role must be 'master' or 'worker'."
  }
}

variable "cpu_cores" {
  description = "Number of CPU cores"
  type        = number
  default     = 8
  validation {
    condition     = var.cpu_cores > 0 && var.cpu_cores <= 256
    error_message = "CPU cores must be between 1 and 256."
  }
}

variable "memory_mb" {
  description = "Memory in MB"
  type        = number
  default     = 32768
  validation {
    condition     = var.memory_mb >= 512
    error_message = "Memory must be at least 512 MB."
  }
}

variable "disk_size_gb" {
  description = "Disk size in GB"
  type        = number
  default     = 100
  validation {
    condition     = var.disk_size_gb >= 10
    error_message = "Disk size must be at least 10 GB."
  }
}

variable "storage" {
  description = "Proxmox storage name"
  type        = string
  default     = "local-lvm"
}

variable "iso_image" {
  description = "ISO image for initial install (empty = cloud-init only)"
  type        = string
  default     = ""
}

# k3s configuration
variable "install_k3s" {
  description = "Whether to install k3s via provisioner"
  type        = bool
  default     = true
}

variable "k3s_version" {
  description = "k3s version to install (e.g., v1.29.6+k3s1)"
  type        = string
  default     = "v1.29.6+k3s1"
  validation {
    condition     = can(regex("^v?\\d+\\.\\d+\\.\\d+", var.k3s_version))
    error_message = "k3s version must be in format vX.Y.Z or X.Y.Z."
  }
}

variable "k3s_token" {
  description = "k3s cluster token (shared secret for cluster joining)"
  type        = string
  sensitive   = true
  validation {
    condition     = length(var.k3s_token) >= 16
    error_message = "k3s token must be at least 16 characters."
  }
}

variable "k3s_master_ip" {
  description = "First master node IP for worker registration (required for workers)"
  type        = string
  default     = ""
}

variable "node_ip" {
  description = "Node IP for k3s (--node-ip and --node-external-ip)"
  type        = string
  default     = ""
}

# Network configuration
variable "network_interfaces" {
  description = "Network interfaces for the VM"
  type        = list(object({
    bridge   = string
    model    = optional(string, "virtio")
    vlan     = optional(number)
    mac      = optional(string)
    firewall = optional(bool, false)
  }))
  default = [
    { bridge = "vmbr0", vlan = 20 },  # k8s-mgmt VLAN
    { bridge = "vmbr0", vlan = 30 },  # ceph-public VLAN
  ]
}

variable "ssh_keys" {
  description = "SSH public keys for cloud-init"
  type        = list(string)
  default     = []
}

variable "ci_user" {
  description = "Cloud-init user"
  type        = string
  default     = "ubuntu"
}

variable "ci_password_hash" {
  description = "Cloud-init password hash (leave empty to use generated password)"
  type        = string
  default     = ""
  sensitive   = true
}

variable "generate_password" {
  description = "Generate random password if ci_password_hash is empty"
  type        = bool
  default     = true
}

variable "dns_servers" {
  description = "DNS servers"
  type        = list(string)
  default     = ["10.10.10.1", "1.1.1.1"]
}

variable "search_domain" {
  description = "DNS search domain"
  type        = string
  default     = "k3s.local"
}

variable "on_boot" {
  description = "Start VM on boot"
  type        = bool
  default     = true
}

variable "agent" {
  description = "Enable QEMU guest agent"
  type        = bool
  default     = true
}

variable "tablet_device" {
  description = "Enable tablet device"
  type        = bool
  default     = true
}

variable "bios" {
  description = "BIOS type (seabios, ovmf)"
  type        = string
  default     = "ovmf"
  validation {
    condition     = contains(["seabios", "ovmf"], var.bios)
    error_message = "BIOS must be 'seabios' or 'ovmf'."
  }
}

variable "efi_disk" {
  description = "Enable EFI disk (required for ovmf)"
  type        = bool
  default     = true
}

variable "machine" {
  description = "Machine type"
  type        = string
  default     = "q35"
  validation {
    condition     = contains(["pc", "q35"], var.machine)
    error_message = "Machine must be 'pc' or 'q35'."
  }
}

variable "cpu_type" {
  description = "CPU type (host for passthrough, kvm64 for compatibility)"
  type        = string
  default     = "host"
}

variable "numa" {
  description = "Enable NUMA"
  type        = bool
  default     = false
}

variable "tags" {
  description = "VM tags"
  type        = list(string)
  default     = ["k3s", "cluster"]
}

# SSH provisioner config
variable "ssh_private_key_path" {
  description = "Path to SSH private key for provisioner"
  type        = string
  default     = "~/.ssh/id_ed25519"
}