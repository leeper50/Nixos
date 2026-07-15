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
      /syncthing
    ]
    ++ [
      agenix.homeManagerModules.default
      stylix.homeModules.stylix
    ];
  home.pointerCursor.enable = true;
  local = {
    restic.backups = {
      home = {
        exclude = [
          "/home/walter/.cache"
          "/home/walter/.local/share/Steam"
          "/home/walter/.local/share/Trash"
          "/home/walter/.steam"
          "/home/walter/Games"
          "/home/walter/Nas"
        ];
        paths = [
          "/home/walter"
        ];
      };
      steam = {
        exclude = [ ];
        paths = [
          "/home/walter/.config/Limo.conf"
          "/home/walter/.config/Limo"
          "/home/walter/.config/unity3d/Ludeon Studios"
          "/home/walter/.local/share/Steam/steamapps/common/Europa Universalis IV/builtin_dlc"
          "/home/walter/.local/share/Steam/steamapps/common/Europa Universalis IV/dlc_metadata"
          "/home/walter/.local/share/Steam/steamapps/common/Europa Universalis IV/dlc"
          "/home/walter/.local/share/Steam/steamapps/common/Rimworld/Mods"
          "/home/walter/.local/share/Steam/steamapps/common/Stardew Valley"
          "/home/walter/.local/share/Steam/steamapps/common/Victoria 3/game/dlc_metadata"
          "/home/walter/.local/share/Steam/steamapps/common/Victoria 3/game/dlc"
          "/home/walter/.local/share/Steam/steamapps/workshop/content/529340/2883019620"
          "/home/walter/.local/share/Paradox Interactive"
          "/home/walter/.paradoxlauncher"
          "/home/walter/Games/Limo"
        ];
      };
    };
    syncthing.folders = {
      "Desktops".enable = true;
      "Downloads".enable = true;
      "FreeTube".enable = true;
      "GlobalShare".enable = true;
      "Notes".enable = true;
      "Phone".enable = true;
      "Tablet".enable = true;
    };
  };
}
