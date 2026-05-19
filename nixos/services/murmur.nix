{ config, ... }:
{
  services.murmur = {
    bandwidth = 192000;
    enable = true;
    logToFile = true;
    openFirewall = true;
    password = config.age.secrets."mumble_server_password.age".path;
    registerHostname = "19280085.xyz";
    registerName = "DaBois";
    registerUrl = "https://19280085.xyz";
    welcometext = "Merry Christmas!!";
  };
}
