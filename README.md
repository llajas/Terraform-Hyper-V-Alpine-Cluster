# A Terraform Module for Hyper-V
A Terraform module that leverages a custom Hyper-V provider (Provided by 'https://github.com/taliesins/terraform-provider-hyperv') that will spin up-to 5 VM's that all run a base Alpine Linux image. Each VM will pull its name from a pool of Puppy type Pokemon and label it accordingly. Additionally, a virtual switch bridged to the local host adapter is created using this module that will allow the VM's to connect to one another and reach out to DHCP on the LAN the Hyper-V host is running on. Each VM will have dynamic RAM that will adjust accordingly, starting at 512MB per instance and can be used for a k8s/k3s cluster via Ansible configuration.

# Prerequisites

First you'll want to expose your Hyper-V host if not on a domain - That can be done via the following instructions: https://github.com/taliesins/terraform-provider-hyperv#setting-up-server-for-provider-usage

You'll need to have already created a base image for these images which can be specified under the 'hyperv_vhd.k3s-host-vhdx' resource group. Simply update this section with your '*.vhdx' image and this will replicate across all instances that you specify.

Additionally, you can either update the 'dvd_drives' subgroup under 'hyperv_machine_instance.k3s-cluster' to point to a '*.iso' file to boot from, or comment it out entirely if a DVD drive isn't needed. In this case, this allows the image to load Alpine Linux into RAM prior to installing to the disk, or configure the disk to run in 'Data Disk Mode' (https://wiki.alpinelinux.org/wiki/Installation#Data_Disk_Mode)

Check any other paths that may be different on your Hyper-V host and update accordingly!

# To-Do

Add more variables for disk and path options for more modularity.