variable "vmcount0" {
  description = "Please enter the amount of VM's you would like to have on host 1"
  type        = number

  validation {
    condition     = var.vmcount0 >= 1 && var.vmcount0 <= 27 && floor(var.vmcount0) == var.vmcount0
    error_message = "Please choose a number between 1-27!"
  }
}
variable "vmcount1" {
  description = "Please enter the amount of VM's you would like to have on host 2"
  type        = number

  validation {
    condition     = var.vmcount1 >= 1 && var.vmcount1 <= 27 && floor(var.vmcount1) == var.vmcount1
    error_message = "Please choose a number between 1-27!"
  }
}
variable "switch_name" {
  type = string
  default = "k8s-net"
}
variable "network_adapter0" {
  description = "Please enter the name of the NIC to be bound/bridged to your virtual switch:"
  type = string
}
variable "network_adapter1" {
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
variable "HYPERV_HOST0" {
  description = "Enter the name (Non-FQDN) of the Windows host"
  type = string  
}
variable "HYPERV_HOST1" {
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
variable "working_path0" {
  description = "Please specify the location used to store all created '.vhdx' files for all nodes"
  type = string
}
variable "working_path1" {
  description = "Please specify the location used to store all created '.vhdx' files for all nodes"
  type = string
}
variable "domain" {
  description = "Please enter the domain that you would like to use for your cluster"
  type = string
  default = ".local"
}