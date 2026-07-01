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
          ../../secrets/agenix.nix
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
    kdePackages.ffmpegthumbs
    kdePackages.kimageformats
    kdePackages.qtimageformats
    kdePackages.qtsvg
    mpvpaper
    qview
  ];
  programs = {
    hyprland = {
      enable = true;
      xwayland.enable = true;
    };
    hyprlock.enable = true;
  };
  security = {
    polkit.enable = true;
  };
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
