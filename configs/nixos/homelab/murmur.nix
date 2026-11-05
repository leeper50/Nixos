{
  config,
  globals,
  lib,
  localLib,
  pkgs,
  secrets,
  ...
}:
let
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
        default = "vc.${globals.domains.primary}";
        type = lib.types.nullOr lib.types.str;
      };
      enable = lib.mkEnableOption "Enable DNS-01 cert challenge";
      provider = lib.mkOption {
        default = "cloudflare";
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
          assertion =
            !(
              config.local.murmur.enable
              && config.local.murmur.tls.enable
              && (config.local.murmur.tls.provider == null || config.local.murmur.tls.domain == null)
            );
          message = "Murmur tls is enabled, but either `tls.provider` or `tls.domain` are not set properly.";
        }
        {
          assertion =
            !(config.local.murmur.enable && config.local.murmur.public && !config.local.murmur.tls.enable);
          message = "Public murmur servers need tls enabled to be registered.";
        }
      ];
    }
    (lib.mkIf config.local.murmur.enable {
      age.secrets = {
        "murmur_environment.age".file = "${secrets}/murmur_environment.age";
        "murmur_superuser_password.age".file = "${secrets}/murmur_superuser_password.age";
      };
      networking.firewall = localLib.mkFirewallRules {
        service = "murmur";
        sources = [
          "0.0.0.0/0"
          "::/0"
        ];
        tcpPorts = [ config.services.murmur.port ];
        udpPorts = [ config.services.murmur.port ];
      };
      services.murmur = {
        bandwidth = 192000;
        enable = true;
        environmentFile = pass."murmur_environment.age".path;
        password = "$MURMUR_PASSWORD";
        welcometext = config.local.murmur.welcomeMessage;
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
    (lib.mkIf (config.local.murmur.enable && config.local.murmur.tls.enable) {
      local.acme = {
        certs.${config.local.murmur.tls.domain} = {
          group = "murmur";
          provider = config.local.murmur.tls.provider;
          wildcard = false;
        };
        enable = true;
      };
      services.murmur.tls.useACMEHost = config.local.murmur.tls.domain;
    })
    (lib.mkIf (config.local.murmur.enable && config.local.murmur.public) {
      services.murmur = {
        password = lib.mkForce "";
        registerHostname = config.local.murmur.tls.domain;
        registerName = config.local.murmur.name;
        registerPassword = "$MURMUR_REGISTER_PASSWORD";
        registerUrl = "https://${config.local.murmur.tls.domain}";
      };
    })
  ];
}
