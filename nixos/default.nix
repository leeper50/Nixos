{
  agenix,
  config,
  home-manager,
  pkgs,
  ...
}:
let
  locale = "en_US.UTF-8";
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
    defaultLocale = locale;
    extraLocaleSettings = {
      LC_ADDRESS = locale;
      LC_IDENTIFICATION = locale;
      LC_MEASUREMENT = locale;
      LC_MONETARY = locale;
      LC_NAME = locale;
      LC_NUMERIC = locale;
      LC_PAPER = locale;
      LC_TELEPHONE = locale;
      LC_TIME = locale;
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
  time.timeZone = "America/Chicago";
  users.users = {
    root = user_settings;
    walter = user_settings // {
      description = "Administrator";
      extraGroups = [
        "networkmanager"
        "walter"
        "wheel"
      ];
      hashedPasswordFile = config.age.secrets."user_walter_hash.age".path;
      isNormalUser = true;
    };
  };
}
