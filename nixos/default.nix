{
  agenix,
  config,
  globals,
  home-manager,
  pkgs,
  ...
}:
let
  user_settings = {
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIxiUaRCIxik4Ptw9JUm/vJiUcKMxEPuGpdf5CZWGZ1Z Walter-PC"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKbDcD3eXAYp+ra3OXFLEDABbvVcBpY5yHEv9JULMBdW wleeper13@outlook.com"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB6fOhJsw36+gRKj2ilD8wvXaI0RHE5uCN86hO5XF25V walter@komodo"
    ];
    shell = pkgs.fish;
  };
in
{
  imports = [
    agenix.nixosModules.default
    home-manager.nixosModules.home-manager
    ../secrets

    # Services
    ./services/ssh.nix
  ];
  boot.kernelPackages = pkgs.linuxPackages_latest;
  environment.systemPackages = with pkgs; [
    btrfs-progs
    busybox
    curl
    ethtool
    git
    iperf
    ncdu
    rclone
    rsync
  ];
  nix = {
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
    optimise = {
      automatic = true;
      dates = [ "12:30" ];
    };
    settings = {
      auto-optimise-store = true;
      experimental-features = [
        "nix-command"
        "flakes"
      ];
    };
  };
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
  programs.fish.enable = true;
  security.sudo = {
    enable = true;
    extraConfig = ''
      Defaults pwfeedback
    '';
    wheelNeedsPassword = true;
  };
  services.tailscale.enable = true;
  time.timeZone = globals.timeZone;
  users = {
    groups = {
      "${globals.username}" = {
        gid = 1000;
        members = [ globals.username ];
      };
    };
    users = {
      root = user_settings;
      ${globals.username} = user_settings // {
        description = "Administrator";
        extraGroups = [
          "networkmanager"
          "wheel"
        ];
        hashedPasswordFile = config.age.secrets."user_${globals.username}_hash.age".path;
        isNormalUser = true;
      };
    };
  };
}
