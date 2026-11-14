# SPDX-License-Identifier: MIT
# Copyright (c) 2026 Vince Bono
variable "node_name" {
  description = "Proxmox node that runs the virtual machines."
  type        = string
  default     = "pve"
}

variable "datastore" {
  description = "Storage for virtual machine disks."
  type        = string
  default     = "local-lvm"
}

variable "image_datastore" {
  description = "Storage for the downloaded base image. It must allow the 'import' content type."
  type        = string
  default     = "local"
}

variable "image_url" {
  description = "Cloud image every virtual machine is built from."
  type        = string
  default     = "https://cloud.debian.org/images/cloud/trixie/latest/debian-13-genericcloud-amd64.qcow2"
}

variable "bridge" {
  description = "Network bridge the virtual machines attach to."
  type        = string
  default     = "vmbr0"
}

variable "gateway" {
  description = "Default gateway for the lab network."
  type        = string
}

variable "username" {
  description = "Administrator account created on every virtual machine."
  type        = string
  default     = "ops"
}

variable "ssh_public_key" {
  description = "Public key allowed to sign in as the administrator account."
  type        = string
}

variable "vms" {
  description = "Virtual machines to create, keyed by host name. 'groups' become Ansible groups and Proxmox tags."
  type = map(object({
    ipv4      = string
    cores     = optional(number, 2)
    memory_mb = optional(number, 2048)
    disk_gb   = optional(number, 20)
    groups    = optional(list(string), [])
  }))

  validation {
    condition     = alltrue([for vm in values(var.vms) : can(cidrhost(vm.ipv4, 0))])
    error_message = "Each ipv4 must be an address with a prefix length, for example 192.168.10.21/24."
  }
}
