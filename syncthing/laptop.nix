{ ... }:
{
  imports = [
    ./nixos.nix
  ];

  local.syncthing.folders = {
    "Desktops".enable = true;
    "Downloads".enable = true;
    "FreeTube".enable = true;
    "GlobalShare".enable = true;
    "Notes".enable = true;
    "Tablet".enable = true;
  };
}
