{
  config,
  globals,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.local.murmur;
  pass = config.age.secrets;
in
{
  options.local.murmur = {
    enable = lib.mkEnableOption "Murmur - A mumble server";
    name = lib.mkOption {
      default = "Main";
      type = lib.types.str;
    };
    public = lib.mkEnableOption "Open & Public server";
    tls = {
      domain = lib.mkOption {
        default = null;
        type = lib.types.nullOr lib.types.str;
      };
      enable = lib.mkEnableOption "Enable DNS-01 cert challenge";
      provider = lib.mkOption {
        default = null;
        type = lib.types.nullOr lib.types.str;
      };
    };
    welcomeMessage = lib.mkOption {
      default = "Merry Christmas!!";
      type = lib.types.str;
    };
  };
  config = lib.mkMerge [
    {
      assertions = [
        {
          assertion = !(cfg.enable && cfg.tls.enable && (cfg.tls.provider == null || cfg.tls.domain == null));
          message = "Murmur tls is enabled, but either `tls.provider` or `tls.domain` are not set properly.";
        }
        {
          assertion = !(cfg.enable && cfg.public && !cfg.tls.enable);
          message = "Public murmur servers need tls enabled to be registered.";
        }
      ];
    }
    (lib.mkIf cfg.enable {
      services.murmur = {
        bandwidth = 192000;
        enable = true;
        environmentFile = pass."murmur_environment.age".path;
        openFirewall = true;
        password = "$MURMUR_PASSWORD";
        welcometext = cfg.welcomeMessage;
      };
      systemd.services.murmur.serviceConfig.RestrictAddressFamilies = lib.mkForce [
        "AF_INET"
        "AF_INET6"
        "AF_NETLINK"
      ];
      systemd.services.murmur-superuser-password = {
        description = "Set Murmur SuperUser password";
        wantedBy = [ "multi-user.target" ];
        after = [ "murmur.service" ];
        requires = [ "murmur.service" ];
        serviceConfig = {
          Type = "oneshot";
          User = "murmur";
          Group = "murmur";
          LoadCredential = "supw:${pass."murmur_superuser_password.age".path}";
          ExecStart = pkgs.writeShellScript "murmur-supw" ''
            ${config.services.murmur.package}/bin/mumble-server \
              -ini /run/murmur/murmurd.ini \
              -supw "$(cat "$CREDENTIALS_DIRECTORY/supw")"
          '';
        };
      };
    })
    (lib.mkIf (cfg.enable && cfg.tls.enable) {
      security.acme = {
        acceptTerms = true;
        defaults.email = globals.primaryEmail;
        certs = {
          ${cfg.tls.domain} = {
            dnsProvider = cfg.tls.provider;
            dnsPropagationCheck = true;
            environmentFile = config.age.secrets."${cfg.tls.provider}_dns_api_token.age".path;
            group = "murmur";
          };
        };
      };
      services.murmur.tls.useACMEHost = cfg.tls.domain;
    })
    (lib.mkIf (cfg.enable && cfg.public) {
      services.murmur = {
        password = lib.mkForce "";
        registerHostname = cfg.tls.domain;
        registerName = cfg.name;
        registerPassword = "$MURMUR_REGISTER_PASSWORD";
        registerUrl = "https://${cfg.tls.domain}";
      };
    })
  ];
}
