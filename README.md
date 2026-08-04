# Nix Configuration Overview

This repository contains my Nix configurations across various machine types, including NixOS, Nix-darwin, and Nix-standalone with Home Manager. The configurations are designed to be customizable for different environments.

To customize this configuration for your needs:

1. Replace values in `globals.nix` with your own.
2. Update the `secrets/secrets.nix` file by replacing secrets and their filenames as necessary.
3. Modify the `home/accounts/default.nix` file according to your requirements.
4. Adjust the `flake.nix` file to match your system configuration.

It is recommended to place this repository in `$HOME/Nix`, as shell functions expect it there.
