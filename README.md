# Nix Configuration Overview

This repository contains my Nix configurations across various machine types, including NixOS, Nix-darwin, and Nix-standalone with Home Manager. 

To customize this configuration for your needs:

1. Replace values in `/globals.nix` with your own.
2. Update the `/secrets/secrets.nix` file by replacing secrets and their filenames as necessary.
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
└── 📁 secrets
    ├── 📄 default.nix (Imports secrets to hosts)
    └── 📄 secrets.nix (Define secret rules here)
```
A service's file should handle everything the service needs to function. (Firewall rules, user/groups & ownership, etc.). A folder may be used for a service if it helps readability. 
Files in `/config/darwin` should only be used by Nix-darwin systems.
Files in `/config/nixos` should only be used by Nixos systems.
Files in `/config/home` may be used by any home-manager systems.
