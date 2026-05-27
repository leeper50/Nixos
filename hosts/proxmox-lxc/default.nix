{ lib, modulesPath, ... }:
{
  imports = [
    (modulesPath + "/virtualisation/proxmox-lxc.nix")
  ];
  networking = {
    defaultGateway = {
      address = "10.0.0.1";
      interface = "eth0";
    };
    networkmanager.enable = lib.mkForce false;
  };
  proxmoxLXC.manageHostName = true;
  users.users.root.initialPassword = "nixos";
}
