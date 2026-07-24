{
  agenix,
  pkgs,
  stylix,
  systemType,
  ...
}:
{
  imports = [
    stylix.nixosModules.stylix
    ../../stylix
    {
      home-manager = {
        extraSpecialArgs = { inherit agenix systemType; };
        useGlobalPkgs = true;
        useUserPackages = true;
        users.walter.imports = [
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
    kdePackages.qtimageformats
    kdePackages.qtsvg
    mpvpaper
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
    displayManager.sddm.enable = true;
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
}
