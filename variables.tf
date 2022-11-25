variable "leader_server_count" {
  description = "How many leader instances should be created?"
  type        = number

  validation {
    condition     = var.server_count >= 1 && var.server_count <= 27 && floor(var.server_count) == var.server_count
    error_message = "Please choose a number between 1-27!"
  }
}
variable "worker_server_count" {
  description = "How many worker instances should be created?"
  type        = number

  validation {
    condition     = var.server_count >= 1 && var.server_count <= 27 && floor(var.server_count) == var.server_count
    error_message = "Please choose a number between 1-27!"
  }
}
variable "switch_name" {
  type = string
  default = "k3s DMZ"
}
variable "network_adapter" {
  type = string
}
variable "HYPERV_USERNAME" {
  description = "Enter the local (Non-Domain Joined) Windows account"
  type = string
}
variable "HYPERV_PASSWORD" {
  description = "Enter the password for the Windows account"
  sensitive = true
  type = string
}
variable "HYPERV_HOST" {
  description = "Enter the name (Non-FQDN) of the Windows host"
  type = string  
}
variable "HYPERV_PORT" {
  type = number
  default = 5986
}
variable "build_notes" {
  default = "Provisioned by Terraform"
}