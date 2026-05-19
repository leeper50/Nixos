{ config, pkgs, ... }:
{
  services.murmur = {
    bandwidth = 192000;
    enable = true;
    logToFile = true;
    openFirewall = true;
    registerHostname = "19280085.xyz";
    registerName = "DaBois";
    registerUrl = "https://19280085.xyz";
    user = "walter";
    welcometext = "Merry Christmas!!";
  };

  # Set serverpassword using agenix
  systemd.services.murmur = {
    serviceConfig = {
      ExecStartPre =
        let
          script = pkgs.writeShellScript "murmur-inject-password" ''
            PASSWORD=$(cat ${config.age.secrets."mumble_server_password.age".path})
            CONFIG=/home/walter/.murmurd/mumble-server.ini
            # Remove any existing serverpassword line, then append the real one
            sed -i '/^serverpassword=/d' "$CONFIG"
            echo "serverpassword=$PASSWORD" >> "$CONFIG"
          '';
        in
        [ "+${script}" ];
    };
  };
}
