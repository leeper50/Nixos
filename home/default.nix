{
  globals,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./shell
  ];

  home = {
    activation = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
      setDefaultApps = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        ${pkgs.duti}/bin/duti -s com.interversehq.qView public.image viewer
      '';
    };
    homeDirectory =
      if pkgs.stdenv.hostPlatform.isLinux then
        "/home/${globals.username}"
      else
        "/Users/${globals.username}";
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
      ++ lib.optionals pkgs.stdenv.hostPlatform.isLinux [
        hwinfo
        trashy
      ]
      ++ lib.optionals pkgs.stdenv.hostPlatform.isDarwin [
        dbgate
        duti
      ];
    shell.enableFishIntegration = true;
    stateVersion = "26.05";
    username = globals.username;
  };
  programs.home-manager.enable = true;
  targets.genericLinux.enable = pkgs.stdenv.hostPlatform.isLinux;
}
