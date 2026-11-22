# The login screen and each enabled user's desktop. Every enabled user's
# desktop is installed; SDDM's Default session starts the logged-in user's.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  userDesktops = config.local.userDesktops;
  desktops = lib.unique (lib.attrValues userDesktops);
  uses = desktop: lib.elem desktop desktops;
  # The same commands as each desktop's own session file. SDDM sets the
  # desktop names from the session file, so set them here instead.
  startDesktop = {
    hyprland = ''
      export XDG_CURRENT_DESKTOP=Hyprland XDG_SESSION_DESKTOP=Hyprland
      exec ${config.programs.uwsm.package}/bin/uwsm start -e -D Hyprland hyprland.desktop
    '';
    plasma =
      let
        plasma-workspace = pkgs.kdePackages.plasma-workspace;
      in
      ''
        export XDG_CURRENT_DESKTOP=KDE XDG_SESSION_DESKTOP=KDE
        exec ${plasma-workspace}/libexec/plasma-dbus-run-session-if-needed ${plasma-workspace}/bin/startplasma-wayland
      '';
    sway = ''
      export XDG_CURRENT_DESKTOP=sway:wlroots XDG_SESSION_DESKTOP=sway
      exec ${config.programs.sway.package}/bin/sway
    '';
  };
  # SDDM remembers one last session for everyone, so this session starts
  # whichever desktop the logged-in user has.
  userSession = pkgs.writeTextFile {
    name = "user-session";
    destination = "/share/wayland-sessions/user.desktop";
    text = ''
      [Desktop Entry]
      Name=Default
      Comment=Your own desktop
      Exec=${pkgs.writeShellScript "user-session" ''
        case "$USER" in
        ${lib.concatStrings (
          lib.mapAttrsToList (name: desktop: ''
            ${name})
              ${startDesktop.${desktop}};;
          '') userDesktops
        )}
        *)
          ${startDesktop.${lib.head desktops}};;
        esac
      ''}
      Type=Application
    '';
    passthru.providedSessions = [ "user" ];
  };
in
{
  config = lib.mkMerge [
    {
      services.displayManager = {
        defaultSession = "user";
        sddm = {
          enable = true;
          # Always preselect the Default session, not the previous user's pick.
          settings.Users.RememberLastSession = false;
          wayland = {
            compositor = "kwin";
            enable = true;
          };
        };
        sessionPackages = [ userSession ];
      };
    }
    (lib.mkIf (uses "hyprland" || uses "sway") {
      environment.systemPackages =
        with pkgs;
        [
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
          libsecret
          mpvpaper
          qview
        ]
        ++ [ config.stylix.cursor.package ];
      services.gnome.gnome-keyring.enable = true;
      xdg.portal.enable = true;
    })
    (lib.mkIf (uses "hyprland") {
      environment.systemPackages = [ pkgs.hyprpaper ];
      programs.hyprland = {
        enable = true;
        withUWSM = true;
        xwayland.enable = true;
      };
    })
    (lib.mkIf (uses "plasma") {
      environment.plasma6.excludePackages = with pkgs.kdePackages; [
        discover
        elisa
        khelpcenter
        krdp
      ];
      services.desktopManager.plasma6.enable = true;
    })
    (lib.mkIf (uses "sway") {
      environment.systemPackages = [ pkgs.awww ];
      programs.sway = {
        enable = true;
        # Do not install sway's extra packages.
        extraPackages = [ ];
      };
    })
  ];
}
