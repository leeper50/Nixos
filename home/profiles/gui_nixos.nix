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
  xdg.mime.defaultApplications = {
    "image/avif" = "com.interversehq.qView.desktop";
    "image/bmp" = "com.interversehq.qView.desktop";
    "image/gif" = "com.interversehq.qView.desktop";
    "image/heic" = "com.interversehq.qView.desktop";
    "image/heif" = "com.interversehq.qView.desktop";
    "image/jpeg" = "com.interversehq.qView.desktop";
    "image/png" = "com.interversehq.qView.desktop";
    "image/svg+xml" = "com.interversehq.qView.desktop";
    "image/tiff" = "com.interversehq.qView.desktop";
    "image/webp" = "com.interversehq.qView.desktop";
    "image/x-bmp" = "com.interversehq.qView.desktop";
    "image/x-portable-bitmap" = "com.interversehq.qView.desktop";
    "image/x-portable-pixmap" = "com.interversehq.qView.desktop";
    "text/html" = "librewolf.desktop";
    "x-scheme-handler/ftp" = "librewolf.desktop";
    "x-scheme-handler/http" = "librewolf.desktop";
    "x-scheme-handler/https" = "librewolf.desktop";
  };
}
