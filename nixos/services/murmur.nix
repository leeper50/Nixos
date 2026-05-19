{ config, pkgs, ... }:
{
  services.murmur = {
    bandwidth = 192000;
    enable = true;
    environmentFile = config.age.secrets."mumble_server_password.age".path;
    logToFile = true;
    openFirewall = true;
    password = "$MURMUR_PASSWORD";
    registerHostname = "19280085.xyz";
    registerName = "DaBois";
    registerUrl = "https://19280085.xyz";
    welcometext = "Merry Christmas!!";
  };
}
