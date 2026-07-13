{ lib, pkgs, ... }:
{
  imports = [
    ./shell
  ];

  home = {
    activation = lib.mkIf pkgs.stdenv.isDarwin {
      setDefaultApps = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        ${pkgs.duti}/bin/duti -s com.interversehq.qView public.image viewer
      '';
    };
    homeDirectory = if pkgs.stdenv.isLinux then "/home/walter" else "/Users/walter";
    packages =
      with pkgs;
      [
        age
        base16-schemes
        bc
        chezmoi
        colmena
        fastfetch
        iperf
        nixd
        nixfmt
        parallel
        powerline-fonts
      ]
      ++ lib.optionals pkgs.stdenv.isLinux [
        hwinfo
      ]
      ++ lib.optionals pkgs.stdenv.isDarwin [
        dbgate
        duti
      ];
    shell.enableFishIntegration = true;
    stateVersion = "25.11";
    username = "walter";
  };
  programs.home-manager.enable = true;
  targets.genericLinux.enable = pkgs.stdenv.isLinux;
}
