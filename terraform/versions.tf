# SPDX-License-Identifier: MIT
# Copyright (c) 2026 Vince Bono
terraform {
  required_version = ">= 1.7"
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.122.0"
    }
  }
}

# Endpoint and API token come from the environment (PROXMOX_VE_ENDPOINT,
# PROXMOX_VE_API_TOKEN), so no secret is ever written to a file here.
provider "proxmox" {}
