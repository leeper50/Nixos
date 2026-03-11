{ config, pkgs, ... }:
let
  user_settings = {
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIxiUaRCIxik4Ptw9JUm/vJiUcKMxEPuGpdf5CZWGZ1Z Walter-PC"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKbDcD3eXAYp+ra3OXFLEDABbvVcBpY5yHEv9JULMBdW wleeper13@outlook.com"
    ];
    shell = pkgs.fish;
  };
in
{
  imports = [
    ./hardware-configuration.nix
  ];

  nix.optimise.automatic = true;
  nix.optimise.dates = [ "03:45" ];
  nix.settings.auto-optimise-store = true;
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Enable networking
  networking = {
    defaultGateway = "10.0.0.1";
    firewall = {
      allowPing = true;
      enable = true;
    };
    hostName = "gk55";
    interfaces.enp1s0 = {
      ipv4.addresses = [
        {
          address = "10.0.0.20";
          prefixLength = 24;
        }
      ];
    };
    nameservers = [
      "10.0.0.40"
      "10.0.0.1"
      "9.9.9.9"
    ];
    networkmanager.enable = true;
    nftables.enable = true;
  };

  # Set your time zone
  time.timeZone = "America/Chicago";

  # Select internationalisation properties
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  programs.fish.enable = true;
  services.openssh.enable = true;

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

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
    btrfs-progs
    busybox
    curl
    git
    samba
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?
}
