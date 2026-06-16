{
  config,
  lib,
  pkgs,
  ...
}:
let
  sslocalBin = "${pkgs.shadowsocks-rust}/bin/sslocal";
  configFile = "${config.home.homeDirectory}/.config/shadowsocks/config.json";
in
{
  home.packages = [ pkgs.shadowsocks-rust ];
  home.file.".config/shadowsocks/config.json".text = builtins.toJSON {
    local_address = "127.0.0.1";
    local_port = 1080;
    method = "chacha20-ietf-poly1305";
    mode = "tcp_and_udp";
    server = "10.0.0.31";
    server_port = 8388;
  };
  systemd.user.services.shadowsocks-client = lib.mkIf pkgs.stdenv.isLinux {
    Install = {
      WantedBy = [ "default.target" ];
    };
    Service = {
      ExecStart = "${sslocalBin} -c ${configFile}";
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
        sslocalBin
        "-c"
        configFile
      ];
      RunAtLoad = true;
      StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/shadowsocks-client.error.log";
      StandardOutPath = "${config.home.homeDirectory}/Library/Logs/shadowsocks-client.log";
    };
  };
}
