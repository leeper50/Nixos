variable "proxmox_endpoint" {
  description = "Base URL of the Proxmox VE API."
  type        = string
}

variable "proxmox_api_token" {
  description = <<-EOT
    Proxmox API token in the form USER@REALM!TOKENID=UUID, e.g.
    terraform@pve!opentofu=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx.
    Create it under Datacenter -> Permissions -> API Tokens.
  EOT
  type        = string
  sensitive   = true

  validation {
    condition     = can(regex("^[^@]+@[^!]+![^=]+=.+$", var.proxmox_api_token))
    error_message = "Expected the full token string in the form USER@REALM!TOKENID=UUID."
  }
}

variable "state_passphrase" {
  description = "Passphrase for OpenTofu state and plan encryption (at least 16 characters)."
  type        = string
  sensitive   = true
}
