{
  config,
  lib,
  pkgs,
  systemType,
  ...
}:
let
  cfg = config.local.packages;
in
{
  options.local.packages.ollama.enable = lib.mkEnableOption "ollama";
  config = lib.mkMerge [
    (lib.mkIf cfg.ollama.enable {
      services.ollama = {
        enable = true;
        environmentVariables."OLLAMA_CONTEXT_LENGTH" = "32768";
        package = pkgs.ollama-vulkan;
      };
    })
    (lib.mkIf (cfg.ollama.enable && systemType == "Nixos" && config.hardware.nvidia.modesetting.enable)
      {
        nix.settings = {
          substituters = [
            "https://cache.nixos-cuda.org"
          ];
          trusted-public-keys = [
            "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M="
          ];
        };
        services.ollama.package = lib.mkForce pkgs.ollama-cuda;
      }
    )
  ];
}
