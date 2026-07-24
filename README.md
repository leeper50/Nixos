# The big ol nix configuration

The repo contains all my nix configurations across many machine types,
and different installation methods (NixOS, Nix-darwin, Nix-standalone+home-manager).

To change this to your needs:
1. Replace values in globals.nix with your own.
2. Change the pretty much everything in the `secrets/secrets.nix` file. Update secrets and their file names.
3. Update the `home/accounts/default.nix` file.
4. Change flake.nix to match your own systems.

It is recommended to keep the repo in `$HOME/Nix` as the shell functions expect it to be there.

