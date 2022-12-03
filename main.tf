terraform {
  required_providers {
    hyperv = {
      source  = "taliesins/hyperv"
      version = "~> 1.0.3"
    }
  }
}

# Host 1
provider "hyperv" {
  alias = "hv0"
  user            = var.HYPERV_USERNAME
  password        = var.HYPERV_PASSWORD
  host            = var.HYPERV_HOST0
  port            = var.HYPERV_PORT
  https           = true
  insecure        = false
  use_ntlm        = true
  tls_server_name = ""
  cacert_path     = ""
  cert_path       = ""
  key_path        = ""
  script_path     = "C:/Temp/terraform_%RAND%.cmd"
  timeout         = "60s"
}
# Host 2
provider "hyperv" {
  alias = "hv1"
  user            = var.HYPERV_USERNAME
  password        = var.HYPERV_PASSWORD
  host            = var.HYPERV_HOST1
  port            = var.HYPERV_PORT
  https           = true
  insecure        = false
  use_ntlm        = true
  tls_server_name = ""
  cacert_path     = ""
  cert_path       = ""
  key_path        = ""
  script_path     = "C:/Temp/terraform_%RAND%.cmd"
  timeout         = "60s"
}

#Create Virtual Switch - Host 1
resource "hyperv_network_switch" "k8s-cluster-net0" {
  provider = hyperv.hv0
  name = var.switch_name
  notes = var.build_notes
  allow_management_os = true
  enable_embedded_teaming = false
  enable_iov = false
  enable_packet_direct = false
  minimum_bandwidth_mode = "None"
  switch_type = "External"
  net_adapter_names = [var.network_adapter0]
  default_flow_minimum_bandwidth_absolute = 0
  default_flow_minimum_bandwidth_weight = 0
  default_queue_vmmq_enabled = false
  default_queue_vmmq_queue_pairs = 16
  default_queue_vrss_enabled = false
}
#Create Virtual Switch - Host 2
resource "hyperv_network_switch" "k8s-cluster-net1" {
  provider = hyperv.hv1
  name = var.switch_name
  notes = var.build_notes
  allow_management_os = true
  enable_embedded_teaming = false
  enable_iov = false
  enable_packet_direct = false
  minimum_bandwidth_mode = "None"
  switch_type = "External"
  net_adapter_names = [var.network_adapter1]
  default_flow_minimum_bandwidth_absolute = 0
  default_flow_minimum_bandwidth_weight = 0
  default_queue_vmmq_enabled = false
  default_queue_vmmq_queue_pairs = 16
  default_queue_vrss_enabled = false
}

#Randomize list of Pokemon Region Names to be used for leaders
resource "random_shuffle" "node_names" {
  input = "${var.node_name_list}"
}

#Create Leader Node(s)
resource "hyperv_machine_instance" "k8s-nodes0" {
  provider = hyperv.hv0
  count = var.vmcount0
  name = random_shuffle.node_names.result[count.index]
  generation = 2
  automatic_critical_error_action = "Pause"
  automatic_critical_error_action_timeout = 30
  automatic_start_action = "Start"
  automatic_start_delay = 0
  automatic_stop_action = "Save"
  checkpoint_type = "Production"
  dynamic_memory = true
  guest_controlled_cache_types = false
  high_memory_mapped_io_space = 536870912
  lock_on_disconnect = "Off"
  low_memory_mapped_io_space = 134217728
  memory_maximum_bytes = 1099511627776
  memory_minimum_bytes = 536870912
  memory_startup_bytes = 2147483648
  notes = var.build_notes
  processor_count = 4
  smart_paging_file_path = "C:\\ProgramData\\Microsoft\\Windows\\Hyper-V"
  snapshot_file_location = "C:\\ProgramData\\Microsoft\\Windows\\Hyper-V"
  state = "Running"

  hard_disk_drives {
    controller_type = "Scsi"
    controller_number = "0"
    controller_location = "0"
    path = hyperv_vhd.node-vhdx0["${count.index}"].path
  }

  network_adaptors {
	name = "eth0"
	switch_name  = hyperv_network_switch.k8s-cluster-net0.name
  }

  vm_firmware {
    enable_secure_boot = "Off"
    secure_boot_template = "MicrosoftWindows"
    preferred_network_boot_protocol = "IPv4"
    console_mode = "Default"
    pause_after_boot_failure = "On"
  }

  vm_processor {
    compatibility_for_migration_enabled               = false
    compatibility_for_older_operating_systems_enabled = false
    enable_host_resource_protection                   = false
    expose_virtualization_extensions                  = false
    hw_thread_count_per_core                          = 0
    maximum                                           = 100
    maximum_count_per_numa_node                       = 4
    maximum_count_per_numa_socket                     = 1
    relative_weight                                   = 100
    reserve                                           = 0
  }
}
#Create Leader Node(s)
resource "hyperv_machine_instance" "k8s-nodes1" {
  provider = hyperv.hv1
  count = var.vmcount1
  name = random_shuffle.node_names.result[count.index+var.vmcount0]
  generation = 2
  automatic_critical_error_action = "Pause"
  automatic_critical_error_action_timeout = 30
  automatic_start_action = "Start"
  automatic_start_delay = 0
  automatic_stop_action = "Save"
  checkpoint_type = "Production"
  dynamic_memory = true
  guest_controlled_cache_types = false
  high_memory_mapped_io_space = 536870912
  lock_on_disconnect = "Off"
  low_memory_mapped_io_space = 134217728
  memory_maximum_bytes = 1099511627776
  memory_minimum_bytes = 536870912
  memory_startup_bytes = 2147483648
  notes = var.build_notes
  processor_count = 4
  smart_paging_file_path = "C:\\ProgramData\\Microsoft\\Windows\\Hyper-V"
  snapshot_file_location = "C:\\ProgramData\\Microsoft\\Windows\\Hyper-V"
  state = "Running"

  hard_disk_drives {
    controller_type = "Scsi"
    controller_number = "0"
    controller_location = "0"
    path = hyperv_vhd.node-vhdx1["${count.index}"].path
  }

  network_adaptors {
	name = "eth0"
	switch_name  = hyperv_network_switch.k8s-cluster-net1.name
  }

  vm_firmware {
    enable_secure_boot = "Off"
    secure_boot_template = "MicrosoftWindows"
    preferred_network_boot_protocol = "IPv4"
    console_mode = "Default"
    pause_after_boot_failure = "On"
  }

  vm_processor {
    compatibility_for_migration_enabled               = false
    compatibility_for_older_operating_systems_enabled = false
    enable_host_resource_protection                   = false
    expose_virtualization_extensions                  = false
    hw_thread_count_per_core                          = 0
    maximum                                           = 100
    maximum_count_per_numa_node                       = 4
    maximum_count_per_numa_socket                     = 1
    relative_weight                                   = 100
    reserve                                           = 0
  }
}

#Create Disk for Each worker VM mirrored from base image
resource "hyperv_vhd" "node-vhdx0" {
  provider = hyperv.hv0
  count = var.vmcount0
  path   = "${var.working_path0}\\nodes\\${random_shuffle.node_names.result[count.index]}\\k8s-hdd.vhdx"
  source = var.base_image_path
}

#Create Disk for Each leader mirrored from base image
resource "hyperv_vhd" "node-vhdx1" {
  provider = hyperv.hv1
  count = var.vmcount1
  path   = "${var.working_path1}\\nodes\\${random_shuffle.node_names.result[count.index+var.vmcount0]}\\k8s-hdd.vhdx"
  source = var.base_image_path
}

# #Generate inventory file for Ansible
# resource "local_file" "ansible_inventory" {
#     depends_on = [
#       hyperv_machine_instance.k8s-leader,hyperv_machine_instance.k8s-worker
#     ]
#     content = templatefile("inventory.tmpl",
#     {
#       hostname_k8s_leader = "${join("\n", [for instance in hyperv_machine_instance.k8s-leader : join("", [instance.id, "${var.domain} ansible_host=", instance.network_adaptors.0.ip_addresses.0])] )}"
#       hostname_k8s_worker = "${join("\n", [for instance in hyperv_machine_instance.k8s-worker : join("", [instance.id, "${var.domain} ansible_host=", instance.network_adaptors.0.ip_addresses.0])] )}"
#     }
#   )
#   filename = "ansible/inventory"
# }

# output "Nodes" {
#   value = ["${hyperv_machine_instance.k8s-leader.*.name}", "${hyperv_machine_instance.k8s-worker.*.name}"]
# }
# output "VLAN" {
#   value = var.switch_name
# }