# SPDX-License-Identifier: MIT
# Copyright (c) 2026 Vince Bono
resource "proxmox_download_file" "image" {
  content_type = "import"
  datastore_id = var.image_datastore
  node_name    = var.node_name
  url          = var.image_url
  file_name    = "homelab-base.qcow2"
}

resource "proxmox_virtual_environment_vm" "vm" {
  for_each = var.vms

  name        = each.key
  description = "Managed by Terraform (homelab-as-code)"
  tags        = sort(concat(["terraform"], each.value.groups))
  node_name   = var.node_name

  # The guest agent is installed later by Ansible, so Proxmox can't ask the guest to shut down yet.
  stop_on_destroy = true

  cpu {
    cores = each.value.cores
    type  = "x86-64-v2-AES"
  }

  memory {
    dedicated = each.value.memory_mb
  }

  disk {
    datastore_id = var.datastore
    import_from  = proxmox_download_file.image.id
    interface    = "scsi0"
    size         = each.value.disk_gb
  }

  initialization {
    datastore_id = var.datastore

    ip_config {
      ipv4 {
        address = each.value.ipv4
        gateway = var.gateway
      }
    }

    user_account {
      username = var.username
      keys     = [trimspace(var.ssh_public_key)]
    }
  }

  network_device {
    bridge = var.bridge
  }

  operating_system {
    type = "l26"
  }

  serial_device {}
}
