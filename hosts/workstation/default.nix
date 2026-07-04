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
  local.restic.backups = {
    home = {
      exclude = [
        "/home/walter/.cache"
        "/home/walter/.local/share/Steam"
        "/home/walter/.local/share/Trash"
        "/home/walter/Nas"
      ];
      paths = [
        "/home/walter"
      ];
    };
    steam = {
      exclude = [ ];
      paths = [
        "/home/walter/.local/share/Steam/steamapps/common/Europa Universalis IV/builtin_dlc"
        "/home/walter/.local/share/Steam/steamapps/common/Europa Universalis IV/dlc_metadata"
        "/home/walter/.local/share/Steam/steamapps/common/Europa Universalis IV/dlc"
        "/home/walter/.local/share/Steam/steamapps/common/Rimworld/Mods"
        "/home/walter/.local/share/Steam/steamapps/common/Victoria 3/game/dlc_metadata"
        "/home/walter/.local/share/Steam/steamapps/common/Victoria 3/game/dlc"
        "/home/walter/.local/share/Steam/steamapps/workshop/529340/2883019620"
      ];
    };
  };
}
