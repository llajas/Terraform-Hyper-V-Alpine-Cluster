terraform {
  required_providers {
    hyperv = {
      source  = "taliesins/hyperv"
      version = "~> 1.0.3"
    }
  }
}

# Configure HyperV
provider "hyperv" {
  user            = var.HYPERV_USERNAME
  password        = var.HYPERV_PASSWORD
  host            = var.HYPERV_HOST
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

#Create Virtual Switch
resource "hyperv_network_switch" "k3s-cluster-net" {
  name = var.switch_name
  notes = var.build_notes
  allow_management_os = true
  enable_embedded_teaming = false
  enable_iov = false
  enable_packet_direct = false
  minimum_bandwidth_mode = "None"
  switch_type = "External"
  net_adapter_names = [var.network_adapter]
  default_flow_minimum_bandwidth_absolute = 0
  default_flow_minimum_bandwidth_weight = 0
  default_queue_vmmq_enabled = false
  default_queue_vmmq_queue_pairs = 16
  default_queue_vrss_enabled = false
}

#Randomize list of Pokemon Names to be used for VM's
resource "random_shuffle" "pokemon" {
  input = "${var.server_names}"
}

#Create Leader Node(s)
resource "hyperv_machine_instance" "k3s-leader" {
  count = var.leader_server_count
  name = random_shuffle.pokemon.result[count.index]
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
    path = hyperv_vhd.k3s-host-vhdx["${count.index}"].path
  }

  network_adaptors {
	name = "eth0"
	switch_name  = hyperv_network_switch.k3s-cluster-net.name
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

#Create Worker Node(s)
resource "hyperv_machine_instance" "k3s-worker" {
  count = var.worker_server_count
  name = random_shuffle.pokemon.result[count.index]
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
  memory_startup_bytes = 536870912
  notes = var.build_notes
  processor_count = 2
  smart_paging_file_path = "C:\\ProgramData\\Microsoft\\Windows\\Hyper-V"
  snapshot_file_location = "C:\\ProgramData\\Microsoft\\Windows\\Hyper-V"
  state = "Running"

  hard_disk_drives {
    controller_type = "Scsi"
    controller_number = "0"
    controller_location = "0"
    path = hyperv_vhd.k3s-host-vhdx["${count.index}"].path
  }

  network_adaptors {
	name = "eth0"
	switch_name  = hyperv_network_switch.k3s-cluster-net.name
	# wait_for_ips = false
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

#Create Disk for Each VM mirrored from base image
resource "hyperv_vhd" "k3s-host-vhdx" {
  count = var.server_count
  path   = "C:\\VMs\\k3s\\vdisk\\${random_shuffle.pokemon.result[count.index]}\\k3s-hdd.vhdx"
  source = "C:\\VMs\\base-image\\Alpine_Linux_Base.vhdx"
}

resource "null_resource" "ansible-inventory" {
  count = var.server_count
	triggers = {
		mytest = timestamp()
	}

	provisioner "local-exec" {
	    command = "echo ${hyperv_machine_instance.k3s-cluster[count.index].id}.k8s.lajas.tech ansible_host=${hyperv_machine_instance.k3s-cluster[count.index].network_adaptors.0.ip_addresses.0}>> 'ansible/inventory'"
      }

	depends_on = [ 
			hyperv_machine_instance.k3s-cluster 
			]
}

output "VMs" {
  value = ["${hyperv_machine_instance.k3s-cluster.*.name}"]
}
output "VLAN" {
  value = var.switch_name
}