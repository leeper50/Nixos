terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.113.1"
    }
  }

  # State is committed to git, so it is always encrypted. The passphrase comes
  # from TF_VAR_state_passphrase (secrets/tofu_env.age, loaded by tofu.fish).
  encryption {
    key_provider "pbkdf2" "state" {
      passphrase = var.state_passphrase
    }

    method "aes_gcm" "state" {
      keys = key_provider.pbkdf2.state
    }

    state {
      method   = method.aes_gcm.state
      enforced = true
    }

    plan {
      method   = method.aes_gcm.state
      enforced = true
    }
  }
}

provider "proxmox" {
  endpoint  = var.proxmox_endpoint
  api_token = var.proxmox_api_token
  insecure  = true
  ssh {
    agent = true
  }
}

locals {
  nixos_vm_defaults = {
    node_name      = "ser8"
    datastore_id   = "local-lvm"
    cores          = 2
    memory         = 2048
    disk_size      = 40
    data_disk_size = 100
    cpu_type       = "host"
    pci_mappings   = []
    usb_mappings   = []
  }

  # Defined per host in flake.nix (`proxmox = { ... }`) and exported with
  # `nix eval --json .#proxmoxVms`. tofu.fish regenerates this file.
  nixos_vms = jsondecode(file("${path.module}/vms.json"))

  nixos_vm_config = {
    for name, vm in local.nixos_vms : name => merge(
      local.nixos_vm_defaults,
      { data_datastore_id = lookup(vm, "datastore_id", local.nixos_vm_defaults.datastore_id) },
      vm,
    )
  }

  nixos_vm_nodes = toset([for vm in local.nixos_vm_config : vm.node_name])
}

resource "proxmox_virtual_environment_vm" "nixos_vm" {
  for_each = local.nixos_vm_config

  name            = each.key
  node_name       = each.value.node_name
  vm_id           = each.value.vm_id
  stop_on_destroy = true
  tags            = ["terraform", "nixos"]

  bios = "ovmf"

  efi_disk {
    datastore_id = each.value.datastore_id
    type         = "4m"
  }

  boot_order = ["virtio0", "ide3"]

  cdrom {
    file_id = proxmox_download_file.nixos_installer_iso[each.value.node_name].id
  }

  agent {
    enabled = false
  }

  cpu {
    cores = each.value.cores
    type  = each.value.cpu_type
  }

  memory {
    dedicated = each.value.memory
    floating  = each.value.memory
  }

  network_device {
    bridge = "vmbr0"
    model  = "virtio"
  }

  disk {
    datastore_id = each.value.datastore_id
    interface    = "virtio0"
    serial       = "${each.key}-root"
    iothread     = true
    discard      = "on"
    size         = each.value.disk_size
  }

  # data_disk_size = 0 means no data disk.
  dynamic "disk" {
    for_each = each.value.data_disk_size > 0 ? [each.value] : []
    content {
      datastore_id = disk.value.data_datastore_id
      interface    = "virtio1"
      serial       = "${each.key}-data"
      iothread     = true
      discard      = "on"
      size         = disk.value.data_disk_size
    }
  }

  dynamic "hostpci" {
    for_each = each.value.pci_mappings
    content {
      device  = "hostpci${hostpci.key}"
      mapping = hostpci.value
    }
  }

  dynamic "usb" {
    for_each = each.value.usb_mappings
    content {
      mapping = usb.value
      usb3    = true
    }
  }

  # Mappings are referenced by name from vms.json, so order them explicitly.
  depends_on = [
    proxmox_hardware_mapping_pci.pci,
    proxmox_hardware_mapping_usb.usb,
  ]

  lifecycle {
    # prevent_destroy = true
  }
}

resource "proxmox_download_file" "nixos_installer_iso" {
  for_each = local.nixos_vm_nodes

  content_type = "iso"
  datastore_id = "local"
  node_name    = each.value
  overwrite    = false
  url          = "https://github.com/nix-community/nixos-images/releases/download/nixos-26.05/nixos-installer-x86_64-linux.iso"
}

resource "proxmox_hardware_mapping_pci" "pci" {
  for_each = {
    tower-igpu = {
      comment      = "tower Intel UHD 730 (node-2 / Jellyfin)"
      node         = "tower"
      id           = "8086:4692"
      path         = "0000:00:02.0"
      subsystem_id = "1043:8882"
      iommu_group  = 0
    }
    tower-sata = {
      comment      = "tower SATA controller with the two WD 8TB drives (nas /mnt/data)"
      node         = "tower"
      id           = "8086:7a62"
      path         = "0000:00:17.0"
      subsystem_id = "1043:8882"
      iommu_group  = 9
    }
  }

  name    = each.key
  comment = each.value.comment
  map = [{
    node         = each.value.node
    id           = each.value.id
    path         = each.value.path
    subsystem_id = each.value.subsystem_id
    iommu_group  = each.value.iommu_group
  }]
}

resource "proxmox_hardware_mapping_usb" "usb" {
  for_each = {
    zigbee = {
      comment = "Sonoff Zigbee 3.0 USB Dongle Plus"
      node    = "ser8"
      id      = "10c4:ea60"
    }
    zwave = {
      comment = "Nabu Casa ZWA-2"
      node    = "ser8"
      id      = "303a:4001"
    }
  }

  name    = each.key
  comment = each.value.comment
  map = [{
    node = each.value.node
    id   = each.value.id
  }]
}
