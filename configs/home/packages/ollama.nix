{
  config,
  globals,
  lib,
  localLib,
  pkgs,
  ...
}:
let
  ollamaInhibit = pkgs.writeShellApplication {
    name = "ollama-inhibit";
    runtimeInputs = [
      pkgs.curl
      pkgs.jq
      pkgs.systemd
    ];
    text = ''
      interval=15
      url=http://127.0.0.1:${toString config.services.ollama.port}/api/ps

      loaded() {
        curl -sf --max-time 2 "$url" | jq -e '.models | length > 0' >/dev/null
      }

      if [ "''${1:-}" = hold ]; then
        while loaded; do
          sleep "$interval"
        done
        exit 0
      fi

      while true; do
        if loaded; then
          systemd-inhibit --what=idle:sleep --who=Ollama --why='Model loaded' "$0" hold
        else
          sleep "$interval"
        fi
      done
    '';
  };
in
{
  options.local.packages.ollama = {
    context_length = lib.mkOption {
      type = lib.types.int;
      default = 4096;
    };
    enable = lib.mkEnableOption "ollama";
  };
  config = lib.mkMerge [
    (lib.mkIf config.local.packages.ollama.enable {
      networking.firewall = localLib.mkFirewallRules {
        service = "ollama";
        sources = globals.networking.lan.subnets;
        tcpPorts = [ 11434 ];
      };
      services.ollama = {
        enable = true;
        environmentVariables = {
          "OLLAMA_CONTEXT_LENGTH" = toString config.local.packages.ollama.context_length;
          "OLLAMA_FLASH_ATTENTION" = "1";
          "OLLAMA_KV_CACHE_TYPE" = "q8_0";
          "OLLAMA_ORIGINS" = "*";
        };
        host = "[::]";
        package = lib.mkDefault pkgs.ollama-vulkan;
      };
      systemd.services.ollama-inhibit = {
        after = [ "ollama.service" ];
        description = "Block sleep while an Ollama model is loaded";
        partOf = [ "ollama.service" ];
        wantedBy = [ "multi-user.target" ];
        wants = [ "ollama.service" ];
        serviceConfig = {
          ExecStart = lib.getExe ollamaInhibit;
          Restart = "always";
          RestartSec = 5;
        };
      };
    })
  ];
}
