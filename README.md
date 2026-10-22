# Nix Configuration Overview

This repository contains my Nix configurations across various machine types, including NixOS, Nix-darwin, and Nix-standalone with Home Manager. 

To customize this configuration for your needs:

1. Replace values in `/globals.nix` with your own.
2. Point the `secrets` input in `/flake.nix` at your own private repo of agenix secrets (with `secrets.nix`, `keys.nix` and `default.nix`), and replace secrets and their filenames as necessary.
3. Modify the `/configs/home/accounts.nix` file according to your requirements.
4. Adjust the `/flake.nix` file to match your system configuration.

It is recommended to place this repository in `$HOME/Nix`, as shell functions expect it there.

To add a new host:
1. Make a folder in the `hosts` folder with its hostname.
2. Setup the host's default.nix file with its specific configs and imports from `/configs`.
3. Set up its flake.nix entry.

The folder structure is:
```
📁 Nix
├── 📁 configs
│   ├── 📁 darwin  (Nix-darwin configs)
│   ├── 📁 home    (Home-manager configs)
│   └── 📁 nixos   (Nixos configs)
├── 📄 flake.lock  (Versioning)
├── 📄 flake.nix   (Define which machines are managed)
├── 📄 globals.nix (Global variables)
├── 📁 hosts
│   ├── 📁 host1   (Host1 configs and imports)
│   └── 📁 host2   (Host2 configs and imports)
├── 📄 justfile    (Shortcuts: `just test`, `just tofu`, `just vm-builder`)
└── 📁 scripts     (Fish scripts the justfile runs)
```

Secrets live in a private repo (`wleeper13/nix-private`), the flake's `secrets` input. Modules read them as `"${secrets}/<name>.age"`. It holds `secrets.nix` (who each secret is encrypted to), `keys.nix` (host and personal public keys) and `default.nix` (checks each host can decrypt its secrets). Keep a clone of it at `./secrets` (ignored by git) to edit secrets with `ragenix`; builds always use the revision locked in `flake.lock`, so after pushing a change there, run `nix flake update secrets` here. NixOS hosts fetch it as root with their SSH host key, which must be a read-only deploy key on the private repo.
A service's file should handle everything the service needs to function. (Firewall rules, user/groups & ownership, `age.secrets` declarations, etc.). A folder may be used for a service if it helps readability. 
Files in `/config/darwin` should only be used by Nix-darwin systems.
Files in `/config/nixos` should only be used by Nixos systems.
Files in `/config/home` may be used by any home-manager systems.

## Proxmox VMs

VMs are created with OpenTofu (`/OpenTofu`) and installed with nixos-anywhere (`just vm-builder`). A VM's Proxmox shape (node, VM id, cores, memory, disks) is set in its `flake.nix` entry as `proxmox = { ... }`. That attribute is exported as `.#proxmoxVms`, written to `OpenTofu/vms.json`, and merged with the defaults in `OpenTofu/main.tf`. Disk serials are `<host>-root` and `<host>-data`, which the disko configs read through `/dev/disk/by-id/virtio-*`.

Tofu state is committed, encrypted. The Proxmox API token and the state passphrase are kept in `secrets/tofu_env.age`, which `just tofu` loads.

To add a VM:
1. Add the host's folder and its `flake.nix` entry, including `proxmox = { ... }`.
2. Run `just vm-builder --key <host>`, add the printed key to `secrets/keys.nix` and as a read-only deploy key on the private secrets repo, then run `ragenix -r` in `secrets/`. Commit and push there, then run `nix flake update secrets` here.
3. Run `just tofu apply` to create the VM. This regenerates `OpenTofu/vms.json` first.
4. Run `just vm-builder --build --root_pass <pass> [--target <ip>] <host>`.
5. Commit the Nix changes, `vms.json` and `terraform.tfstate` together.
