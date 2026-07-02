{ ... }:
{
  imports = [
    ./base.nix
  ];

  local.syncthing.folders = {
    "Desktops".enable = true;
    "Downloads".enable = true;
    "GlobalShare".enable = true;
    "Notes".enable = true;
    "Phone".enable = true;
    "Tablet".enable = true;
  };
}
