{ config, ... }:
let
  posts.webui = 9090;
in
{
  services.cockpit = {
    allowed-origins = [
      "https://${config.networking.hostName}.local:${toString posts.webui}"
    ];
    enable = true;
    openFirewall = true;
    port = posts.webui;
    settings.WebService.AllowUnencrypted = true;
  };
}
