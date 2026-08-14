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
  options.local.packages.ollama = {
    context_length = lib.mkOption {
      type = lib.types.int;
      default = 4096;
    };
    enable = lib.mkEnableOption "ollama";
  };
  config = lib.mkMerge [
    (lib.mkIf cfg.ollama.enable {
      services.ollama = {
        enable = true;
        environmentVariables = {
          "OLLAMA_CONTEXT_LENGTH" = toString cfg.ollama.context_length;
          "OLLAMA_ORIGINS" = "*";
        };
        package = pkgs.ollama-vulkan;
      };
    })
    (lib.mkIf cfg.ollama.enable (
      if systemType == "Standalone" then
        {
          home.packages = with pkgs; [
            claude-code
            jan
          ];
        }
      else
        {
          environment.systemPackages = with pkgs; [
            claude-code
            jan
          ];
        }
    ))
  ];
}
