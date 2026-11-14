# SPDX-License-Identifier: MIT
# Copyright (c) 2026 Vince Bono
# Runs against a mock provider, so it needs no Proxmox server.
mock_provider "proxmox" {}

variables {
  gateway        = "192.168.10.1"
  ssh_public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIexample test@example"
  vms = {
    web1 = { ipv4 = "192.168.10.21/24", groups = ["docker"] }
    db1  = { ipv4 = "192.168.10.22/24", cores = 4, memory_mb = 8192 }
  }
}

run "one_vm_per_entry_with_defaults" {
  command = plan

  assert {
    condition     = length(proxmox_virtual_environment_vm.vm) == 2
    error_message = "Expected one virtual machine per entry in var.vms."
  }
  assert {
    condition     = proxmox_virtual_environment_vm.vm["web1"].memory[0].dedicated == 2048
    error_message = "web1 should get the default memory."
  }
  assert {
    condition     = proxmox_virtual_environment_vm.vm["db1"].cpu[0].cores == 4
    error_message = "db1 should keep its own core count."
  }
}

run "inventory_lists_hosts_and_groups" {
  command = plan

  assert {
    condition     = strcontains(output.inventory, "web1 ansible_host=192.168.10.21\n")
    error_message = "Inventory should list web1 with its address and no prefix length."
  }
  assert {
    condition     = strcontains(output.inventory, "[docker]\nweb1\n")
    error_message = "Inventory should put web1 in the docker group."
  }
  assert {
    condition     = !strcontains(output.inventory, "[docker]\nweb1\ndb1")
    error_message = "db1 is not in the docker group."
  }
}

run "rejects_address_without_prefix_length" {
  command = plan

  variables {
    vms = { bad = { ipv4 = "192.168.10.21" } }
  }
  expect_failures = [var.vms]
}
