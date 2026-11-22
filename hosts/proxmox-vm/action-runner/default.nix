{ disko, ... }:
{
  imports = [
    ../../../configs/nixos/homelab/forgejo.nix
    (import ../vm-disk-config.nix { dataMountpoint = null; })
    disko.nixosModules.disko
  ];
  local = {
    forgejo.runner = {
      enable = true;
      nixHost = true;
      uuid = "04f4e7b8-0cb7-4a22-82ce-d29e2be00bf5";
    };
    lan.enable = true;
    users.walter.enable = false;
  };
  system.stateVersion = "25.11";
}
