# Wacky NAS setup

## Goals
Solid, secure, and extensible nixos configuration for a NAS now that truenas is 

## How to use
1. Change the username to one you want to use. Must change files `flake.nix` and `configuration.nix`.
2. Grab your nixos target's public system ssh key `cat /etc/ssh/ssh_host_ed25519_key.pub`. Put this in the `secrets/secret.nix` key list.
3. Setup your desired secrets in the format user_$username_hashed.age or user_$username_clear.age.
The hashed password is used for the linux user's account. Use `openssl passwd` to generated the hash.
The cleartext password is used for samba account registration.
4. Make sure the network interface is accurate. Releveant file is `configuration.nix`.
5. Change the hostname in flake.nix to what you want, and ensure that when you build, the hostname is in use.