{
  config,
  lib,
  pkgs,
  ...
}:
let
  singBoxBin = "${pkgs.sing-box}/bin/sing-box";
  configFile = "${config.home.homeDirectory}/.config/sing-box/config.json";
  startScript = pkgs.writeShellScript "sing-box-start" ''
    mkdir -p "$(dirname ${configFile})"
    ${pkgs.jq}/bin/jq -n \
      --arg password "$(cat ${config.age.secrets."user_walter_clear.age".path})" \
      '{
        inbounds: [
          {
            listen_port: 1080,
            listen: "127.0.0.1",
            tag: "socks-in",
            tcp_fast_open: true,
            type: "socks"
          }
        ],
        outbounds: [
          {
            default: "tailscale",
            outbounds: ["lan", "tailscale"],
            tag: "proxy",
            type: "selector"
          },
          {
            method: "chacha20-ietf-poly1305",
            password: $password,
            server_port: 8388,
            server: "10.0.0.31",
            tag: "lan",
            type: "shadowsocks"
          },
          {
            method: "chacha20-ietf-poly1305",
            password: $password,
            server_port: 8388,
            server: "100.121.87.44",
            tag: "tailscale",
            type: "shadowsocks"
          }
        ],
        route: {
          final: "proxy"
        }
      }' > ${configFile}
    exec ${singBoxBin} run -c ${configFile}
  '';
in
{
  home.packages = [ pkgs.sing-box ];
  systemd.user.services.sing-box = lib.mkIf pkgs.stdenv.isLinux {
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
      Description = "sing-box proxy client";
    };
  };
  launchd.agents.sing-box = lib.mkIf pkgs.stdenv.isDarwin {
    enable = true;
    config = {
      KeepAlive = true;
      Label = "sing-box";
      ProgramArguments = [
        "${pkgs.bash}/bin/bash"
        "${startScript}"
      ];
      RunAtLoad = true;
      StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/sing-box.error.log";
      StandardOutPath = "${config.home.homeDirectory}/Library/Logs/sing-box.log";
    };
  };
}
