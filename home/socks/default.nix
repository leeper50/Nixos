{
  config,
  lib,
  pkgs,
  ...
}:
let
  sslocalBin = "${pkgs.shadowsocks-rust}/bin/sslocal";
  configFile = "${config.home.homeDirectory}/.config/shadowsocks/config.json";
  startScript = pkgs.writeShellScript "shadowsocks-start" ''
    mkdir -p "$(dirname ${configFile})"
    ${pkgs.jq}/bin/jq -n \
      --arg password "$(cat ${config.age.secrets."user_walter_clear.age".path})" \
      '{
        locals: [
          {
            local_address: "127.0.0.1",
            local_port: 1080,
            mode: "tcp_and_udp",
          }
        ],
        servers: [
          {
            method: "chacha20-ietf-poly1305",
            password: $password,
            server_port: 8388,
            server: "100.121.87.44"
          },
          {
            method: "chacha20-ietf-poly1305",
            password: $password,
            server_port: 8388,
            server: "10.0.0.31"
          }
        ]
      }' > ${configFile}
    exec ${sslocalBin} -c ${configFile}
  '';
in
{
  home.packages = [ pkgs.shadowsocks-rust ];
  systemd.user.services.shadowsocks-client = lib.mkIf pkgs.stdenv.isLinux {
    Install = {
      WantedBy = [ "default.target" ];
    };
    Service = {
      ExecStart = "${startScript}";
      Restart = "on-failure";
      RestartSec = 5;
    };
    Unit = {
      After = [ "network.target" ];
      Description = "Shadowsocks-rust local client";
    };
  };
  launchd.agents.shadowsocks-client = lib.mkIf pkgs.stdenv.isDarwin {
    enable = true;
    config = {
      KeepAlive = true;
      Label = "shadowsocks-client";
      ProgramArguments = [
        "${pkgs.bash}/bin/bash"
        "${startScript}"
      ];
      RunAtLoad = true;
      StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/shadowsocks-client.error.log";
      StandardOutPath = "${config.home.homeDirectory}/Library/Logs/shadowsocks-client.log";
    };
  };
}
