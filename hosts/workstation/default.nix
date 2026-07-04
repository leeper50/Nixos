{
  agenix,
  stylix,
  ...
}:
let
  rootDir = ../..;
in
{
  imports =
    map (p: rootDir + p) [
      /home/profiles/gui_linux.nix
      /restic
      /secrets
      /stylix
      /syncthing/workstation.nix
    ]
    ++ [
      agenix.homeManagerModules.default
      stylix.homeModules.stylix
    ];
  local.restic.backups.home = {
    exclude = [
      "/home/walter/.cache"
      "/home/walter/.local/share/Steam"
    ];
    paths = [
      "/home/walter"
    ];
  };
}
