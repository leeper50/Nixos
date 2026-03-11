# Wacky NAS setup

## Goals
Solid, secure, and extensible nixos configuration for a NAS now that truenas is 

## How to use
1. Change the username to one you want to use. Must change files `flake.nix` and `configuration.nix`.
2. Replace the public keys in the `secrets/secrets.nix` file with your own.
Grab your nixos server's public ssh key using this command `cat /etc/ssh/ssh_host_ed25519_key.pub`.
3. Setup your desired secrets in the format user_$username_hash.age or user_$username_clear.age.
Enter the secrets directory and run the command `agenix -e filename.age` to edit.
The hashed password is used for the linux user's account. Use `openssl passwd` to generated the hash.
The cleartext password is used for samba account registration.
4. Make sure the network interface is accurate. Releveant file is `configuration.nix`.
5. Change the hostname in `flake.nix` to what you want, and ensure that when you build, the hostname is in use.
