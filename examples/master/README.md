<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.6.0 |
| <a name="requirement_proxmox"></a> [proxmox](#requirement\_proxmox) | ~> 0.111 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_random"></a> [random](#provider\_random) | 3.9.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_master_1"></a> [master\_1](#module\_master\_1) | ../../ | n/a |
| <a name="module_master_2"></a> [master\_2](#module\_master\_2) | ../../ | n/a |
| <a name="module_master_3"></a> [master\_3](#module\_master\_3) | ../../ | n/a |

## Resources

| Name | Type |
|------|------|
| [random_password.k3s_token](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_proxmox_api_token"></a> [proxmox\_api\_token](#input\_proxmox\_api\_token) | Proxmox API token (format: USER@REALM!TOKENID=UUID) | `string` | n/a | yes |
| <a name="input_proxmox_api_url"></a> [proxmox\_api\_url](#input\_proxmox\_api\_url) | Proxmox API URL | `string` | n/a | yes |
| <a name="input_proxmox_insecure"></a> [proxmox\_insecure](#input\_proxmox\_insecure) | Skip TLS verification | `bool` | `true` | no |
| <a name="input_ssh_keys"></a> [ssh\_keys](#input\_ssh\_keys) | SSH public keys for cloud-init | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_k3s_token"></a> [k3s\_token](#output\_k3s\_token) | n/a |
| <a name="output_kubeconfig_1"></a> [kubeconfig\_1](#output\_kubeconfig\_1) | n/a |
| <a name="output_master_1_ip"></a> [master\_1\_ip](#output\_master\_1\_ip) | n/a |
| <a name="output_master_2_ip"></a> [master\_2\_ip](#output\_master\_2\_ip) | n/a |
| <a name="output_master_3_ip"></a> [master\_3\_ip](#output\_master\_3\_ip) | n/a |
<!-- END_TF_DOCS -->