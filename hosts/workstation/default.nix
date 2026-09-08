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
      /configs/home/gui.nix
      /configs/home/packages
      /configs/home/restic.nix
      /configs/home/stylix.nix
      /configs/home/syncthing.nix
      /secrets
    ]
    ++ [
      agenix.homeManagerModules.default
      stylix.homeModules.stylix
    ];
  local = {
    browsers = {
      brave.enable = true;
      firefox.enable = true;
      librewolf.enable = true;
    };
    packages = {
      cream-linux.enable = true;
      elegoo-slicer.enable = true;
      ollama = {
        context_length = 32768;
        enable = true;
      };
      waifu2x.enable = true;
    };
    restic.backups = {
      home = {
        exclude = [
          "*cache*"
          "/home/${globals.username}/.local/share/Steam"
          "/home/${globals.username}/.local/share/Trash"
          "/home/${globals.username}/.ollama"
          "/home/${globals.username}/.steam"
          "/home/${globals.username}/Games"
          "/home/${globals.username}/Nas"
          "/home/${globals.username}/Temp"
        ];
        paths = [
          "/home/${globals.username}"
        ];
        targets = [
          "hetzner"
          "nas"
        ];
      };
      steam = {
        exclude = [ ];
        paths = [
          "/home/${globals.username}/.config/Limo.conf"
          "/home/${globals.username}/.config/Limo"
          "/home/${globals.username}/.config/unity3d/Ludeon Studios"
          "/home/${globals.username}/.local/share/Aspyr/Sid Meier's Civilization 5/MODS"
          "/home/${globals.username}/.local/share/Paradox Interactive"
          "/home/${globals.username}/.local/share/Steam/steamapps/common/Europa Universalis IV/builtin_dlc"
          "/home/${globals.username}/.local/share/Steam/steamapps/common/Europa Universalis IV/dlc_metadata"
          "/home/${globals.username}/.local/share/Steam/steamapps/common/Europa Universalis IV/dlc"
          "/home/${globals.username}/.local/share/Steam/steamapps/common/Rimworld/Mods"
          "/home/${globals.username}/.local/share/Steam/steamapps/common/Stardew Valley"
          "/home/${globals.username}/.local/share/Steam/steamapps/common/Victoria 3/game/dlc_metadata"
          "/home/${globals.username}/.local/share/Steam/steamapps/common/Victoria 3/game/dlc"
          "/home/${globals.username}/.local/share/Steam/steamapps/workshop/content/529340/2883019620"
          "/home/${globals.username}/.local/share/Steam/steamapps/workshop/content/236850/1193125267"
          "/home/${globals.username}/.paradoxlauncher"
          "/home/${globals.username}/Games/Limo"
        ];
        targets = [
          "hetzner"
          "nas"
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
