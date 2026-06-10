{ ... }:
{
  imports = [
    ./nixos.nix
  ];

  local.syncthing.folders = {
    "Desktops".enable = true;
    "Downloads".enable = true;
    "GlobalShare".enable = true;
    "Notes".enable = true;
    "Retroarch".enable = true;
    "Tablet".enable = true;
  };
}
