{
  config,
  globals,
  lib,
  secrets,
  ...
}:
let
  cfg = config.local.renovate;
  pass = config.age.secrets;
in
{
  options.local.renovate = {
    enable = lib.mkEnableOption "renovate";
  };
  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      age.secrets."renovate_github_token.age".file = "${secrets}/renovate_github_token.age";
      age.secrets."renovate_token.age".file = "${secrets}/renovate_token.age";
      services.renovate = {
        enable = true;
        credentials = {
          RENOVATE_GITHUB_COM_TOKEN = pass."renovate_github_token.age".path;
          RENOVATE_TOKEN = pass."renovate_token.age".path;
        };
        runtimePackages = [ config.nix.package ];
        schedule = "hourly";
        settings = {
          autodiscover = true;
          endpoint = "https://${globals.forgejo.domain}/api/v1";
          gitAuthor = "Renovate <renovate@noreply.localhost>";
          onboarding = true;
          optimizeForDisabled = true;
          persistRepoData = true;
          platform = "forgejo";
          repositoryCache = "enabled";
        };
      };
    })
  ];
}
