variable "leader_server_count" {
  description = "How many leader instances should be created?"
  type        = number

  validation {
    condition     = var.leader_server_count >= 1 && var.leader_server_count <= 3 && floor(var.leader_server_count) == var.leader_server_count
    error_message = "Please choose a number between 1-3!"
  }
}
variable "worker_server_count" {
  description = "How many worker instances should be created?"
  type        = number

  validation {
    condition     = var.worker_server_count >= 1 && var.worker_server_count <= 27 && floor(var.worker_server_count) == var.worker_server_count
    error_message = "Please choose a number between 1-27!"
  }
}
variable "switch_name" {
  type = string
  default = "k8s DMZ"
}
variable "network_adapter" {
  description = "Please enter the name of the NIC to be bound/bridged to your virtual switch:"
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
variable "base_image_path" {
  description = "Please specify the '.vhdx' file that will be cloned for all nodes"
  type = string
}
variable "working_path" {
  description = "Please specify the location used to store all created '.vhdx' files for all nodes"
  type = string
}