{
  agenix,
  globals,
  lib,
  pkgs,
  ...
}:
let
  rootDir = ../..;
in
{
  imports =
    map (p: rootDir + p) [
      /configs/home/profiles/gui.nix
      /configs/home/syncthing.nix
      /secrets
    ]
    ++ [
      agenix.homeManagerModules.default
    ];

  home = {
    activation = {
      setDefaultApps = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        ${pkgs.duti}/bin/duti -s com.interversehq.qView public.image viewer
      '';
    };
    packages = with pkgs; [
      dbgate
      duti
      libreoffice-bin
      vlc-bin
      wireguard-tools
    ];
  };
  local = {
    browsers = {
      brave.enable = true;
      firefox.enable = true;
      librewolf.enable = true;
    };
    syncthing = {
      folders = {
        "Desktops".enable = true;
        "Downloads".enable = true;
        "GlobalShare".enable = true;
        "Notes".enable = true;
        "Phone".enable = true;
        "Tablet".enable = true;
      };
      home = "/Users/${globals.username}";
    };
  };
}
