{ lib, modulesPath, ... }:
{
  imports = [
    (modulesPath + "/virtualisation/proxmox-lxc.nix")
  ];
  networking = {
    defaultGateway = {
      interface = "eth0";
    };
    networkmanager.enable = lib.mkForce false;
  };
  proxmoxLXC.manageHostName = true;
  users.users.root.initialPassword = "nixos";
}
