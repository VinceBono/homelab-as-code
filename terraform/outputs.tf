# SPDX-License-Identifier: MIT
# Copyright (c) 2026 Vince Bono
locals {
  groups = distinct(flatten([for vm in values(var.vms) : vm.groups]))
}

output "inventory" {
  description = "Ansible inventory for the virtual machines. Save it with: terraform output -raw inventory > ../ansible/inventory.ini"
  value = join("\n", concat(
    ["[all:vars]", "ansible_user=${var.username}", "", "[lab]"],
    [for name, vm in var.vms : "${name} ansible_host=${split("/", vm.ipv4)[0]}"],
    flatten([for g in local.groups : concat(["", "[${g}]"], [for name, vm in var.vms : name if contains(vm.groups, g)])]),
    [""],
  ))
}
