{ lib, modulesPath, ... }:
{
  imports = [
    (modulesPath + "/virtualisation/proxmox-lxc.nix")
  ];
  # proxmox-lxc.nix enables networkd; force-disable NetworkManager to avoid conflicts
  networking.networkmanager.enable = lib.mkForce false;
}
