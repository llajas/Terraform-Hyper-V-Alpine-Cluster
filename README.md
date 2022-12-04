# A Terraform Module for Hyper-V
This is a custom Terraform module that is meant to create the standalone VM's meant for [llajas/homelab](https://github.com/llajas/homelab) prior to initial bootstrapping. It leverages a custom Hyper-V provider (Provided by [taliesins/terraform-provider-hyperv](https://github.com/taliesins/terraform-provider-hyperv)) and will create any amount of VM's your specify with a blank VHDX attached ready for PXE boot across two physical hosts

The following is established when ran:
1. Any number VM's of your choice across two hosts - VM's obtain their names from a pool of starter type Pokemon (Gen1-9).
2. Virtual switches that are bridged externally to a host adapter of your choosing.
3. Cloned VHDX files from a pre-existing file in a location that you specify.

The networking is bridged to allow the VM's to connect to one another and reach out to the same DHCP server that the VLAN the Hyper-V host is running on and obtain PxE boot information where a customized Fedora install takes place based on the MAC address of the VM.
 
 to being bootstrapping via PxE and then further configuration via Ansible. Dynamic RAM is enabled for the nodes, with 2048MB on boot (Less was tested and it was found that the PxE boot runs into issues during bootstraping)

# Prerequisites

First you'll want to expose your Hyper-V host if not on a domain - That can be done via the following instructions: https://github.com/taliesins/terraform-provider-hyperv#setting-up-server-for-provider-usage

You'll also need to have already created a base VHDX image for your machines to clone from with expansion enabled.

# To-Do

~~Pipe MAC addresses into the future 'metal.yml' file which is fed into the initial PxE container, allowing VM's to obtain custom bootstrap.~~ - Addresses are now obtained from the state file and parsed out correctly to be pulled by the Ansible setup.
Break parts up into modules