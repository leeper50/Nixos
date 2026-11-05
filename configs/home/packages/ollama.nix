{
  config,
  lib,
  pkgs,
  systemType,
  ...
}:
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
      services.ollama = {
        enable = true;
        environmentVariables = {
          "OLLAMA_CONTEXT_LENGTH" = toString config.local.packages.ollama.context_length;
          "OLLAMA_ORIGINS" = "*";
        };
        package = pkgs.ollama-vulkan;
      };
    })
    (lib.mkIf config.local.packages.ollama.enable (
      if systemType == "Standalone" then
        {
          home.packages = with pkgs; [
            claude-code
          ];
        }
      else
        {
          environment.systemPackages = with pkgs; [
            claude-code
          ];
        }
    ))
  ];
}
