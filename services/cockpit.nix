{ ... }:
{
  services.cockpit = {
    allowed-origins = [
      "https://gk55.local:9090"
      "https://ser8.local:9090"
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
