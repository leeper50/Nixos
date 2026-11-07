{
  config,
  globals,
  lib,
  pkgs,
  profile,
  secrets,
  ...
}:
let
  familyHome =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        bitwarden-desktop
        collabora-desktop
        firefox
        rustdesk
        thunderbird
      ];
    };
  users = {
    walter = {
      admin = true;
      description = "Administrator";
      gid = 1000;
      homeModules = [ (if profile == "gui" then ../home/gui.nix else ../home) ];
    };
    carrie.homeModules = [ familyHome ];
    david.homeModules = [ familyHome ];
  };
  enabled = lib.filterAttrs (name: _: config.local.users.${name}.enable) users;
  adminSettings = {
    openssh.authorizedKeys.keys = [
      globals.sshKeys.email
      globals.sshKeys.workstation
    ];
    shell = pkgs.fish;
  };
in
{
  options.local.users = lib.mapAttrs (name: _: {
    enable = lib.mkEnableOption "Enable the ${name} user" // {
      default = name == "walter";
    };
  }) users;
  config = {
    age.secrets = lib.mapAttrs' (
      name: _: lib.nameValuePair "user_${name}_hash.age" { file = "${secrets}/user_${name}_hash.age"; }
    ) enabled;
    home-manager.users = lib.mapAttrs (_: user: {
      imports = user.homeModules or [ ];
      home.stateVersion = lib.mkDefault config.system.stateVersion;
    }) enabled;
    users = {
      mutableUsers = false;
      groups = lib.mapAttrs (_: user: { gid = user.gid or null; }) enabled;
      users = {
        root = adminSettings;
      }
      // lib.mapAttrs (
        name: user:
        {
          description = user.description or (lib.toSentenceCase name);
          extraGroups = [
            "users"
          ]
          ++ lib.optionals (user.admin or false) [
            "networkmanager"
            "wheel"
          ]
          ++ lib.optionals (profile == "gui") [
            "audio"
            "input"
            "video"
          ];
          group = name;
          hashedPasswordFile = config.age.secrets."user_${name}_hash.age".path;
          isNormalUser = true;
        }
        // lib.optionalAttrs (user.admin or false) adminSettings
      ) enabled;
    };
  };
}
