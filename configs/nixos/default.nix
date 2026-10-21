{
  agenix,
  config,
  globals,
  home-manager,
  lib,
  nix-flatpak,
  pkgs,
  profile,
  stylix,
  systemType,
  ...
}:
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
  options.local = {
    local = lib.mkEnableOption "local";
  };
  imports = [
    agenix.nixosModules.default
    home-manager.nixosModules.home-manager
    ../../secrets
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
    {
      home-manager = {
        extraSpecialArgs = {
          inherit
            agenix
            globals
            nix-flatpak
            systemType
            ;
        };
        useGlobalPkgs = true;
        useUserPackages = true;
        users.walter.imports = [ ];
      };
    }
  ]
  ++ lib.optionals (profile == "gui") [
    stylix.nixosModules.stylix
    ../home/stylix.nix
    {
      home-manager.users.walter.imports = [
        ../home/gui.nix
      ];
    }
  ]
  ++ lib.optionals (profile == "cli") [
    {
      home-manager.users.walter.imports = [
        ../home
      ];
    }
  ];
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
      age.secrets."user_walter_hash.age".file = ../../secrets/user_walter_hash.age;
      boot.kernelPackages = pkgs.linuxPackages_latest;
      environment.systemPackages = with pkgs; [
        attic-client
        btrfs-progs
        busybox
        curl
        dig
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
      local.comin.enable = true;
      networking.hostName = globals.hostName;
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
      users = {
        mutableUsers = false;
        groups = {
          "walter" = {
            gid = 1000;
            members = [ "walter" ];
          };
        };
        users = {
          root = user_settings;
          walter = user_settings // {
            description = "Administrator";
            extraGroups = [
              "networkmanager"
              "wheel"
            ];
            group = "walter";
            hashedPasswordFile = config.age.secrets."user_walter_hash.age".path;
            isNormalUser = true;
          };
        };
      };
    }
    (lib.mkIf (profile == "gui") (
      let
        sddm-astronaut =
          (pkgs.sddm-astronaut.override {
            embeddedTheme = "japanese_aesthetic";
            themeConfig = {
              Background = "Backgrounds/wallpaper.jxl";

              # === Base 16 Gruvbox Colors ===
              HeaderTextColor = "#d5c4a1";
              DateTextColor = "#d5c4a1";
              TimeTextColor = "#d5c4a1";

              FormBackgroundColor = "#282828";
              BackgroundColor = "#282828";
              DimBackgroundColor = "#282828";

              LoginFieldBackgroundColor = "#3c3836";
              PasswordFieldBackgroundColor = "#3c3836";
              LoginFieldTextColor = "#d5c4a1";
              PasswordFieldTextColor = "#d5c4a1";
              UserIconColor = "#d5c4a1";
              PasswordIconColor = "#d5c4a1";

              PlaceholderTextColor = "#665c54";
              WarningColor = "#fb4934";

              LoginButtonTextColor = "#ebdbb2";
              LoginButtonBackgroundColor = "#504945";
              SystemButtonsIconsColor = "#d5c4a1";
              SessionButtonTextColor = "#d5c4a1";
              VirtualKeyboardButtonTextColor = "#d5c4a1";

              DropdownTextColor = "#ebdbb2";
              DropdownSelectedBackgroundColor = "#665c54";
              DropdownBackgroundColor = "#504945";

              HighlightTextColor = "#ebdbb2";
              HighlightBackgroundColor = "#504945";
              HighlightBorderColor = "transparent";

              HoverUserIconColor = "#665c54";
              HoverPasswordIconColor = "#665c54";
              HoverSystemButtonsIconsColor = "#665c54";
              HoverSessionButtonTextColor = "#665c54";
              HoverVirtualKeyboardButtonTextColor = "#665c54";
            };
          }).overrideAttrs
            (oldAttrs: {
              installPhase = oldAttrs.installPhase + ''
                chmod u+w $out/share/sddm/themes/sddm-astronaut-theme/Backgrounds/
                cp ${../home/wallpaper.jxl} \
                  $out/share/sddm/themes/sddm-astronaut-theme/Backgrounds/wallpaper.jxl
              '';
            });
      in
      {
        age.secrets =
          lib.genAttrs
            [
              "restic_b2_env.age"
              "restic_password_file.age"
              "restic_rustfs_env.age"
              "user_walter_clear.age"
            ]
            (name: {
              file = ../../secrets/${name};
              group = "walter";
              owner = "walter";
            });
        environment.systemPackages =
          with pkgs;
          [
            awww
            hyprpaper
            kdePackages.ark
            kdePackages.dolphin
            kdePackages.kio
            kdePackages.kio-extras
            kdePackages.kdegraphics-thumbnailers
            kdePackages.kwallet
            kdePackages.ffmpegthumbs
            kdePackages.kimageformats
            kdePackages.qt5compat
            kdePackages.qtdeclarative
            kdePackages.qtimageformats
            kdePackages.qtmultimedia
            kdePackages.qtsvg
            kdePackages.qtvirtualkeyboard
            lan-mouse
            libsecret
            mpvpaper
            sddm-astronaut
            qview
          ]
          ++ [ config.stylix.cursor.package ];
        networking.firewall.allowedUDPPorts = [ 4242 ];
        programs = {
          hyprland = {
            enable = true;
            withUWSM = true;
            xwayland.enable = true;
          };
          sway.enable = true;
          steam = {
            enable = true;
            extest.enable = true;
            extraCompatPackages = with pkgs; [
              proton-ge-bin
            ];
            extraPackages = with pkgs; [
              gamescope
            ];
            gamescopeSession.enable = true;
            localNetworkGameTransfers.openFirewall = true;
            protontricks.enable = true;
            remotePlay.openFirewall = true;
          };
        };
        security.polkit.enable = true;
        services = {
          displayManager.sddm = {
            enable = true;
            package = pkgs.kdePackages.sddm;
            theme = "sddm-astronaut-theme";
            wayland = {
              compositor = "kwin";
              enable = true;
            };
          };
          flatpak.enable = true;
          gnome.gnome-keyring.enable = true;
          hypridle.enable = lib.mkForce false;
          printing.enable = true;
          pulseaudio.enable = false;
          pipewire = {
            alsa.enable = true;
            alsa.support32Bit = true;
            enable = true;
            pulse.enable = true;
          };
          udisks2.enable = true;
          xserver.enable = true;
        };
        xdg.portal.enable = true;
      }
    ))
  ];
}
