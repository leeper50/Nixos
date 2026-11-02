{
  config,
  globals,
  lib,
  pkgs,
  secrets,
  ...
}:
let
  cfg = config.local.renovate;
  pass = config.age.secrets;
  deployKey = "forgejo-deploy-key";
in
{
  options.local.renovate = {
    enable = lib.mkEnableOption "renovate";
  };
  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      age.secrets."renovate_github_token.age".file = "${secrets}/renovate_github_token.age";
      age.secrets."renovate_token.age".file = "${secrets}/renovate_token.age";
      age.secrets."renovate_deploy_key.age".file = "${secrets}/renovate_deploy_key.age";
      systemd.services.renovate.serviceConfig.LoadCredential = [
        "${deployKey}:${pass."renovate_deploy_key.age".path}"
      ];
      programs.ssh = {
        extraConfig = ''
          Match host ${globals.forgejo.domain} localuser renovate
            IdentityFile /run/credentials/renovate.service/${deployKey}
            IdentitiesOnly yes
            ConnectTimeout 5
        '';
        knownHosts.forgejo = {
          hostNames = [ "[${globals.forgejo.domain}]:${toString globals.forgejo.sshPort}" ];
          publicKey = globals.forgejo.sshHostKey;
        };
      };
      services.renovate = {
        enable = true;
        credentials = {
          RENOVATE_GITHUB_COM_TOKEN = pass."renovate_github_token.age".path;
          RENOVATE_TOKEN = pass."renovate_token.age".path;
        };
        runtimePackages = [
          config.nix.package
          pkgs.openssh
        ];
        schedule = "*:0/5";
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
