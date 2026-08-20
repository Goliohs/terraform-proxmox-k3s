<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.6.0 |
| <a name="requirement_proxmox"></a> [proxmox](#requirement\_proxmox) | ~> 0.111 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_gpu_worker"></a> [gpu\_worker](#module\_gpu\_worker) | ../../ | n/a |
| <a name="module_worker_1"></a> [worker\_1](#module\_worker\_1) | ../../ | n/a |
| <a name="module_worker_2"></a> [worker\_2](#module\_worker\_2) | ../../ | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_k3s_master_ip"></a> [k3s\_master\_ip](#input\_k3s\_master\_ip) | First master node IP for worker registration | `string` | n/a | yes |
| <a name="input_k3s_token"></a> [k3s\_token](#input\_k3s\_token) | k3s cluster token (shared secret) | `string` | n/a | yes |
| <a name="input_proxmox_api_token"></a> [proxmox\_api\_token](#input\_proxmox\_api\_token) | Proxmox API token (format: USER@REALM!TOKENID=UUID) | `string` | n/a | yes |
| <a name="input_proxmox_api_url"></a> [proxmox\_api\_url](#input\_proxmox\_api\_url) | Proxmox API URL | `string` | n/a | yes |
| <a name="input_proxmox_insecure"></a> [proxmox\_insecure](#input\_proxmox\_insecure) | Skip TLS verification | `bool` | `true` | no |
| <a name="input_ssh_keys"></a> [ssh\_keys](#input\_ssh\_keys) | SSH public keys for cloud-init | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_gpu_worker_ip"></a> [gpu\_worker\_ip](#output\_gpu\_worker\_ip) | n/a |
| <a name="output_worker_1_ip"></a> [worker\_1\_ip](#output\_worker\_1\_ip) | n/a |
| <a name="output_worker_2_ip"></a> [worker\_2\_ip](#output\_worker\_2\_ip) | n/a |
<!-- END_TF_DOCS -->