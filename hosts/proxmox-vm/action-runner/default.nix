{ disko, ... }:
let
  rootDir = ../../..;
  homelab = rootDir + /configs/nixos/homelab;
in
{
  imports = map (p: homelab + p) [ /forgejo.nix ] ++ [
    disko.nixosModules.disko
    (import ../vm-disk-config.nix { dataMountpoint = null; })
  ];
  local = {
    forgejo.runner = {
      enable = true;
      nixHost = true;
      uuid = "04f4e7b8-0cb7-4a22-82ce-d29e2be00bf5";
    };
    local = true;
    networking.tailscale.enable = false;
    walter.enable = false;
  };
  system.stateVersion = "25.11";
}
