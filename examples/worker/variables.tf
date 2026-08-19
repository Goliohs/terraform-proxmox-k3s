variable "proxmox_api_url" {
  description = "Proxmox API URL"
  type        = string
}

variable "proxmox_user" {
  description = "Proxmox API user"
  type        = string
}

variable "proxmox_password" {
  description = "Proxmox API password"
  type        = string
  sensitive   = true
}

variable "proxmox_insecure" {
  description = "Skip TLS verification"
  type        = bool
  default     = true
}

variable "ssh_keys" {
  description = "SSH public keys for cloud-init"
  type        = list(string)
  default     = []
}

variable "k3s_token" {
  description = "k3s cluster token (shared secret)"
  type        = string
  sensitive   = true
}

variable "k3s_master_ip" {
  description = "First master node IP for worker registration"
  type        = string
}