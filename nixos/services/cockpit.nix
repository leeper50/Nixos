{ config, ... }:
{
  services.cockpit = {
    allowed-origins = [
      "https://${config.networking.hostName}.local:9090"
    ];
    enable = true;
    openFirewall = true;
    port = 9090;
    settings = {
      WebService = {
        AllowUnencrypted = true;
      };
    };
  };
}
