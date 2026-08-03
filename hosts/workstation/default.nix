{
  agenix,
  globals,
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
  local = {
    restic.backups = {
      home = {
        exclude = [
          "/home/${globals.username}/.cache"
          "/home/${globals.username}/.local/share/Steam"
          "/home/${globals.username}/.local/share/Trash"
          "/home/${globals.username}/.steam"
          "/home/${globals.username}/Games"
          "/home/${globals.username}/Nas"
        ];
        paths = [
          "/home/${globals.username}"
        ];
      };
      steam = {
        exclude = [ ];
        paths = [
          "/home/${globals.username}/.config/Limo.conf"
          "/home/${globals.username}/.config/Limo"
          "/home/${globals.username}/.config/unity3d/Ludeon Studios"
          "/home/${globals.username}/.local/share/Aspyr/Sid Meier's Civilization 5/MODS/glorious pc master race (v 2)/"
          "/home/${globals.username}/.local/share/Paradox Interactive"
          "/home/${globals.username}/.local/share/Steam/steamapps/common/Europa Universalis IV/builtin_dlc"
          "/home/${globals.username}/.local/share/Steam/steamapps/common/Europa Universalis IV/dlc_metadata"
          "/home/${globals.username}/.local/share/Steam/steamapps/common/Europa Universalis IV/dlc"
          "/home/${globals.username}/.local/share/Steam/steamapps/common/Rimworld/Mods"
          "/home/${globals.username}/.local/share/Steam/steamapps/common/Stardew Valley"
          "/home/${globals.username}/.local/share/Steam/steamapps/common/Victoria 3/game/dlc_metadata"
          "/home/${globals.username}/.local/share/Steam/steamapps/common/Victoria 3/game/dlc"
          "/home/${globals.username}/.local/share/Steam/steamapps/workshop/content/529340/2883019620"
          "/home/${globals.username}/.paradoxlauncher"
          "/home/${globals.username}/Games/Limo"
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
