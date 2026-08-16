{
  agenix,
  globals,
  pkgs,
  stylix,
  systemType,
  ...
}:
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
          cp ${../../stylix/wallpaper.jxl} \
            $out/share/sddm/themes/sddm-astronaut-theme/Backgrounds/wallpaper.jxl
        '';
      });
in
{
  imports = [
    stylix.nixosModules.stylix
    ../../stylix
    {
      home-manager = {
        extraSpecialArgs = { inherit agenix globals systemType; };
        useGlobalPkgs = true;
        useUserPackages = true;
        users.${globals.username}.imports = [
          agenix.homeManagerModules.default
          ../../secrets
          ./gui_linux.nix
        ];
      };
    }
  ];
  environment.systemPackages = with pkgs; [
    awww
    hyprpaper
    kdePackages.ark
    kdePackages.dolphin
    kdePackages.kio
    kdePackages.kio-extras
    kdePackages.kdegraphics-thumbnailers
    kdePackages.kwallet
    kdePackages.kwallet-pam
    kdePackages.ffmpegthumbs
    kdePackages.kimageformats
    kdePackages.qt5compat
    kdePackages.qtdeclarative
    kdePackages.qtimageformats
    kdePackages.qtmultimedia
    kdePackages.qtsvg
    kdePackages.qtvirtualkeyboard
    mpvpaper
    sddm-astronaut
    # rimsort
    qview
  ];
  programs = {
    hyprland = {
      enable = true;
      xwayland.enable = true;
    };
    hyprlock.enable = true;
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
      wayland.enable = true;
    };
    flatpak.enable = true;
    printing.enable = true;
    pulseaudio.enable = false;
    pipewire = {
      alsa.enable = true;
      alsa.support32Bit = true;
      enable = true;
      pulse.enable = true;
    };
    xserver.enable = true;
  };
  xdg.portal.enable = true;
}
