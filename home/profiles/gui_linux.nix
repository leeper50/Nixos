{ pkgs, ... }:
{
  imports = [
    ./gui.nix
    ../desktop/hyprland.nix
  ];
  xdg.mimeApps = {
    enable = true;
    defaultApplicationPackages = with pkgs; [
      audacious
      helix
      kdePackages.ark
      kdePackages.dolphin
      firefox
      qview
      gimp
      mpv
      thunderbird
      vscode
      zathura
    ];
    # associations.added = {
    #   "inode/directory" = [ "code.desktop" ];
    # };
    # associations.removed = {
    #   "inode/directory" = [ "org.pwmt.zathura-cb.desktop" ];
    # };
    defaultApplications = {
      #   # KDE Apps
      #   "application/gzip" = [ "org.kde.ark.desktop" ];
      #   "application/vnd.ms-cab-compressed" = [ "org.kde.ark.desktop" ];
      #   "application/vnd.rar" = [ "org.kde.ark.desktop" ];
      #   "application/x-7z-compressed" = [ "org.kde.ark.desktop" ];
      #   "application/x-archive" = [ "org.kde.ark.desktop" ];
      #   "application/x-bcpio" = [ "org.kde.ark.desktop" ];
      #   "application/x-bzip-compressed-tar" = [ "org.kde.ark.desktop" ];
      #   "application/x-bzip" = [ "org.kde.ark.desktop" ];
      #   "application/x-cd-image" = [ "org.kde.ark.desktop" ];
      #   "application/x-compress" = [ "org.kde.ark.desktop" ];
      #   "application/x-compressed-tar" = [ "org.kde.ark.desktop" ];
      #   "application/x-cpio-compressed" = [ "org.kde.ark.desktop" ];
      #   "application/x-cpio" = [ "org.kde.ark.desktop" ];
      #   "application/x-iso9660-appimage" = [ "org.kde.ark.desktop" ];
      #   "application/x-lha" = [ "org.kde.ark.desktop" ];
      #   "application/x-lrzip-compressed-tar" = [ "org.kde.ark.desktop" ];
      #   "application/x-lz4-compressed-tar" = [ "org.kde.ark.desktop" ];
      #   "application/x-lzip-compressed-tar" = [ "org.kde.ark.desktop" ];
      #   "application/x-lzma-compressed-tar" = [ "org.kde.ark.desktop" ];
      #   "application/x-lzma" = [ "org.kde.ark.desktop" ];
      #   "application/x-rar" = [ "org.kde.ark.desktop" ];
      #   "application/x-source-rpm" = [ "org.kde.ark.desktop" ];
      #   "application/x-sv4cpio" = [ "org.kde.ark.desktop" ];
      #   "application/x-sv4crc" = [ "org.kde.ark.desktop" ];
      #   "application/x-tar " = [ "org.kde.ark.desktop" ];
      #   "application/x-tarz" = [ "org.kde.ark.desktop" ];
      #   "application/x-tzo" = [ "org.kde.ark.desktop" ];
      #   "application/x-xar" = [ "org.kde.ark.desktop" ];
      #   "application/x-xz-compressed-tar" = [ "org.kde.ark.desktop" ];
      #   "application/x-xz" = [ "org.kde.ark.desktop" ];
      #   "application/x-zstd-compressed-tar" = [ "org.kde.ark.desktop" ];
      #   "application/zip" = [ "org.kde.ark.desktop" ];
      #   "application/zstd" = [ "org.kde.ark.desktop" ];

      #   # My stuff
      "inode/directory" = [
        "org.kde.dolphin.desktop"
        "Helix.desktop"
        "code.desktop"
      ];
      #   "image/avif" = [ "com.interversehq.qView.desktop" ];
      #   "image/bmp" = [ "com.interversehq.qView.desktop" ];
      #   "image/gif" = [ "com.interversehq.qView.desktop" ];
      #   "image/heic" = [ "com.interversehq.qView.desktop" ];
      #   "image/heif" = [ "com.interversehq.qView.desktop" ];
      #   "image/jpeg" = [ "com.interversehq.qView.desktop" ];
      #   "image/png" = [ "com.interversehq.qView.desktop" ];
      #   "image/svg+xml" = [ "com.interversehq.qView.desktop" ];
      #   "image/tiff" = [ "com.interversehq.qView.desktop" ];
      #   "image/webp" = [ "com.interversehq.qView.desktop" ];
      #   "image/x-bmp" = [ "com.interversehq.qView.desktop" ];
      #   "image/x-portable-bitmap" = [ "com.interversehq.qView.desktop" ];
      #   "image/x-portable-pixmap" = [ "com.interversehq.qView.desktop" ];
      #   "text/html" = [ "librewolf.desktop" ];
      #   "x-scheme-handler/ftp" = [ "librewolf.desktop" ];
      #   "x-scheme-handler/http" = [ "librewolf.desktop" ];
      #   "x-scheme-handler/https" = [ "librewolf.desktop" ];
      #   "x-scheme-handler/mailto" = [ "thunderbird.desktop" ];
    };
  };
}
