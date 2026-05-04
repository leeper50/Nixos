{ lib, modulesPath, ... }:
{
  imports = [
    (modulesPath + "/virtualisation/proxmox-lxc.nix")
  ];
  networking.networkmanager.enable = lib.mkForce false;
  users.users.root.initialPassword = "nixos";
}
