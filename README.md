# Terraform Proxmox k3s Module

[![Terraform](https://img.shields.io/badge/Terraform-1.6+-623CE4?logo=terraform)](https://terraform.io)
[![Proxmox Provider](https://img.shields.io/badge/Proxmox-0.60+-E57000?logo=proxmox)](https://registry.terraform.io/providers/bpg/proxmox)
[![License](https://img.shields.io/badge/License-MIT-green)](LICENSE)
[![Validate](https://github.com/Goliohs/terraform-proxmox-k3s/actions/workflows/validate.yml/badge.svg)](https://github.com/Goliohs/terraform-proxmox-k3s/actions/workflows/validate.yml)

> **Terraform module to provision k3s Kubernetes nodes on Proxmox VE** with cloud-init, automatic k3s installation, and HA cluster support.

---

## Features

- **Proxmox VE native** — Uses `bpg/proxmox` provider, no external dependencies
- **k3s HA ready** — Bootstrap master with `--cluster-init`, join workers automatically
- **cloud-init** — Full network, SSH, user configuration via cloud-init
- **Multi-VLAN support** — k8s-mgmt, Ceph public/cluster, storage, GPU networks
- **GPU worker support** — Pre-configured for AI/ML workloads with GPU passthrough
- **Secure defaults** — OVMF/UEFI, QEMU guest agent, random passwords, sensitive outputs
- **Flexible sizing** — Master (8C/32GB), Worker (16C/64GB), GPU Worker (32C/128GB)

---

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
                    Proxmox Cluster (3+ nodes)
└─────────────────────────────────────────────────────────────────┘
          │                    │                    │
    ┌─────▼─────┐        ┌─────▼─────┐        ┌─────▼─────┐
    │  Master 1 │        │  Master 2 │        │  Master 3 │
    │  8C/32GB  │        │  8C/32GB  │        │  8C/32GB  │
    │  10.10.20.110     │  10.10.20.111     │  10.10.20.112
    │  Bootstrap        │  HA Server       │  HA Server
    └─────────────────┬─┴─────────────────┬─┴─────────────────┘
                      │ k3s Token        │
    ┌─────────────────▼─────────────────┐
    │         Worker Nodes              │
    │  ┌─────────┐  ┌─────────┐  ┌─────▼─────┐
    │  │Worker 1 │  │Worker 2 │  │ GPU Worker│
    │  │16C/64GB │  │16C/64GB │  │32C/128GB  │
    │  │10.20.120│  │10.20.121│  │10.20.130  │
    │  └─────────┘  └─────────┘  └───────────┘
    └─────────────────────────────────────────┘
```

---

## Quickstart

### Prerequisites

- Terraform >= 1.6.0
- Proxmox VE 7.x or 8.x
- Proxmox API token with `VM.Allocate`, `VM.Config.Disk`, `VM.Config.Network`, `VM.PowerMgmt` permissions
- SSH key pair for cloud-init

### Basic Usage

```hcl
module "k3s_master_1" {
  source  = "Goliohs/proxmox-k3s"
  version = "1.0.0"

  # Proxmox connection
  proxmox_api_url          = "https://proxmox.example.com:8006/api2/json"
  proxmox_api_token_id     = "terraform@pam!terraform"
  proxmox_api_token_secret = "your-secret-here"

  # VM config
  create            = true
  vm_id             = 100
  name              = "k3s-master-1"
  target_node       = "proxmox-node-1"
  role              = "master"
  cpu_cores         = 8
  memory_mb         = 32768
  disk_size_gb      = 100

  # k3s config
  k3s_version       = "v1.29.6+k3s1"
  k3s_token         = "your-shared-cluster-token-min-16-chars"
  k3s_master_ip     = "10.10.20.110"
  node_ip           = "10.10.20.110"

  # Network (VLANs)
  network_interfaces = [
    { bridge = "vmbr0", vlan = 20 },  # k8s-mgmt
    { bridge = "vmbr0", vlan = 30 },  # ceph-public
  ]

  # SSH
  ssh_keys             = ["ssh-ed25519 AAAA..."]
  ci_user              = "ubuntu"
  ssh_private_key_path = "~/.ssh/id_ed25519"
}
```

---

## Examples

| Example | Description |
|---------|-------------|
| [examples/master](examples/master) | 3-node HA master cluster with shared token |
| [examples/worker](examples/worker) | Worker nodes + GPU worker for AI/ML |

```bash
# Deploy masters
cd examples/master
cp variables.tf.example variables.tf  # Fill in your values
terraform init && terraform apply

# Deploy workers (after masters are up)
cd ../worker
cp variables.tf.example variables.tf
terraform init && terraform apply
```

---

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| proxmox_api_url | Proxmox API URL | `string` | - | yes |
| proxmox_api_token_id | Proxmox API token ID | `string` | - | yes |
| proxmox_api_token_secret | Proxmox API token secret | `string` | - | yes |
| proxmox_insecure | Skip TLS verification | `bool` | `true` | no |
| create | Whether to create the VM | `bool` | `true` | no |
| vm_id | Unique VM ID (100-999999999) | `number` | - | yes |
| name | VM name/hostname | `string` | - | yes |
| target_node | Proxmox node to deploy on | `string` | - | yes |
| role | Node role: master or worker | `string` | - | yes |
| cpu_cores | CPU cores | `number` | `8` | no |
| memory_mb | Memory in MB | `number` | `32768` | no |
| disk_size_gb | Disk size in GB | `number` | `100` | no |
| storage | Proxmox storage name | `string` | `local-lvm` | no |
| k3s_version | k3s version to install | `string` | `v1.29.6+k3s1` | no |
| k3s_token | k3s cluster token (16+ chars) | `string` | - | yes |
| k3s_master_ip | First master IP (for workers) | `string` | `""` | no |
| node_ip | Node IP for k3s (--node-ip) | `string` | `""` | no |
| network_interfaces | Network interfaces list | `list(object)` | See below | no |
| ssh_keys | SSH public keys for cloud-init | `list(string)` | `[]` | no |
| ci_user | Cloud-init user | `string` | `ubuntu` | no |
| generate_password | Generate random password | `bool` | `true` | no |
| dns_servers | DNS servers | `list(string)` | `["10.10.10.1","1.1.1.1"]` | no |
| search_domain | DNS search domain | `string` | `k3s.local` | no |
| k3s_version | k3s version to install | `string` | `v1.29.6+k3s1` | no |

**Default network_interfaces:**
```hcl
[
  { bridge = "vmbr0", vlan = 20 },  # k8s-mgmt
  { bridge = "vmbr0", vlan = 30 },  # ceph-public
]
```

---

## Outputs

| Name | Description |
|------|-------------|
| vm_id | VM ID in Proxmox |
| vm_name | VM name |
| vm_target_node | Proxmox node where VM is deployed |
| vm_ip_mgmt | Management/k8s API IP |
| k3s_token | k3s cluster token (sensitive) |
| role | Node role (master/worker) |
| generated_password | Generated password (sensitive) |
| kubeconfig_command | Command to fetch kubeconfig (masters only) |

---

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.6.0 |
| proxmox (bpg/proxmox) | >= 0.60.0 |
| random (hashicorp/random) | >= 3.6.0 |
| null (hashicorp/null) | >= 3.2.0 |

---

## Proxmox Permissions

The API token needs these permissions on the target node(s):
- `VM.Allocate`
- `VM.Config.Disk`
- `VM.Config.Network`
- `VM.Config.Options`
- `VM.PowerMgmt`
- `Datastore.AllocateSpace` (on target storage)

---

## Network Design (VLANs)

| VLAN | ID | Purpose | Bridge |
|------|-----|---------|--------|
| k8s-mgmt | 20 | k3s API, etcd, node communication | vmbr0 |
| ceph-public | 30 | Ceph client access (S3, CSI) | vmbr0 |
| ceph-cluster | 40 | OSD replication | vmbr0 |
| storage | 50 | NFS, iSCSI, MinIO | vmbr0 |
| gpu | 60 | GPU inference workloads | vmbr0 |

---

## License

MIT License — see [LICENSE](LICENSE) for details.

---

## Author

**Oscar Reyes (Goliohs)** — DevOps/ML Infra Engineer
- GitHub: [@Goliohs](https://github.com/Goliohs)
- Portfolio: [services.o7team.us](https://services.o7team.us)