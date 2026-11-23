{
  agenix,
  config,
  globals,
  home-manager,
  lib,
  nix-flatpak,
  pkgs,
  plasma-manager,
  profile,
  systemType,
  secrets,
  ...
}:
{
  options.local.lan.enable = lib.mkEnableOption "settings for hosts on the home LAN";
  imports = [
    agenix.nixosModules.default
    home-manager.nixosModules.home-manager
    "${secrets}/default.nix"
    ../home/restic.nix
    ./acme.nix
    ./avahi.nix
    ./beszel.nix
    ./caddy.nix
    ./comin.nix
    ./fail2ban.nix
    ./mounts.nix
    ./networking.nix
    ./ssh.nix
    ./users.nix
    {
      home-manager = {
        extraSpecialArgs = {
          inherit
            agenix
            globals
            nix-flatpak
            plasma-manager
            secrets
            systemType
            ;
        };
        useGlobalPkgs = true;
        useUserPackages = true;
      };
    }
  ]
  ++ lib.optional (profile == "gui") ./gui;
  config = lib.mkMerge [
    {
      _module.args.localLib = import ./lib { inherit config globals lib; };
      assertions = [
        {
          assertion = (profile == "gui" || profile == "cli");
          message = "The system's profile setting must be either gui or cli. Currently set to ${profile}.";
        }
      ];
    }
    {
      boot.kernelPackages = pkgs.linuxPackages_latest;
      environment.systemPackages = with pkgs; [
        attic-client
        btrfs-progs
        busybox
        curl
        dig
        dix
        ethtool
        git
        iperf
        ncdu
        nmap
        rsync
        tcpdump
      ];
      i18n = {
        defaultLocale = globals.locale;
        extraLocaleSettings = {
          LC_ADDRESS = globals.locale;
          LC_IDENTIFICATION = globals.locale;
          LC_MEASUREMENT = globals.locale;
          LC_MONETARY = globals.locale;
          LC_NAME = globals.locale;
          LC_NUMERIC = globals.locale;
          LC_PAPER = globals.locale;
          LC_TELEPHONE = globals.locale;
          LC_TIME = globals.locale;
        };
      };
      local = {
        beszel.agent.enable = lib.mkDefault true;
        comin.enable = lib.mkDefault true;
      };
      networking.hostName = globals.hostName;
      nix = {
        gc = {
          automatic = true;
          dates = "weekly";
          options = "--delete-older-than 7d";
        };
        settings = {
          auto-optimise-store = true;
          connect-timeout = 5;
          experimental-features = [
            "nix-command"
            "flakes"
          ];
          extra-substituters = [ globals.attic.url ];
          extra-trusted-public-keys = [ globals.attic.publicKey ];
          fallback = true;
        };
      };
      programs.fish.enable = true;
      security.sudo = {
        enable = true;
        extraConfig = ''
          Defaults pwfeedback
        '';
        wheelNeedsPassword = true;
      };
      time.timeZone = globals.timeZone;
    }
  ];
}
