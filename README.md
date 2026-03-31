# The big ol nix configuration

The repo contains all my nix configurations across many machine types (workstation, laptop, server),
and different installation methos (NixOS, Nix-darwin, Nix-standalone+home-manager).

To change this to your needs, replace all instances of the user `walter` with yours and update the secrets.

For nixos systems, pull the repo to the `/etc/nixos` folder (or anywhere and symlink to `/etc/nixos`).
For non-nixos systems, pull the repo to `$HOME/Nix`.
