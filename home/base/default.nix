{ lib, pkgs, ... }:
{
  home.homeDirectory = if pkgs.stdenv.isLinux then "/home/walter" else "/Users/walter";
  home.shell.enableFishIntegration = true;
  home.stateVersion = "25.11";
  home.username = "walter";

  home.packages =
    with pkgs;
    [
      age
      base16-schemes
      bc
      fastfetch
      nixd
      nixfmt
      parallel
      powerline-fonts
      tailscale
    ]
    ++ lib.optionals pkgs.stdenv.isDarwin [
      chezmoi
      dbgate
      duti
    ];

  home.activation = lib.mkIf pkgs.stdenv.isDarwin {
    setDefaultApps = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      ${pkgs.duti}/bin/duti -s com.interversehq.qView public.image viewer
    '';
  };

  targets.genericLinux.enable = pkgs.stdenv.isLinux;

  programs = {
    topgrade = {
      enable = true;
      settings = {
        misc = {
          disable = [
            "chezmoi"
            "claude_code"
            "containers"
            "dotnet"
            "firmware"
            "gearlever"
            "helix"
            "home_manager"
            "nix"
            "shell"
            "vscode"
            "vscodium"
          ];
        };
      };
    };
    home-manager.enable = true;
  };
}
