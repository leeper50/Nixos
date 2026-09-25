{
  config,
  globals,
  lib,
  ...
}:
let
  cfg = config.local.acme;
in
{
  options.local.acme = {
    enable = lib.mkEnableOption "acme";
    certs = lib.mkOption {
      default = { };
      type = lib.types.attrsOf (
        lib.types.submodule {
          options = {
            group = lib.mkOption {
              default = if config.services.caddy.enable then "caddy" else "acme";
              type = lib.types.str;
            };
            provider = lib.mkOption {
              default = "cloudflare";
              type = lib.types.enum [
                "cloudflare"
                "porkbun"
              ];
            };
            wildcard = lib.mkOption {
              default = true;
              type = lib.types.bool;
            };
          };
        }
      );
    };
  };
  config = lib.mkIf cfg.enable {
    # Add machine-specific cert to attrSet as default.
    local.acme.certs."${config.networking.hostName}.${globals.domain}" = { };

    security.acme = {
      acceptTerms = true;
      defaults.email = globals.primaryEmail;
      certs = lib.mapAttrs (name: options: {
        dnsPropagationCheck = true;
        dnsProvider = options.provider;
        dnsResolver = "1.1.1.1:53";
        environmentFile = config.age.secrets."acme_${options.provider}.age".path;
        extraDomainNames = lib.optional options.wildcard "*.${name}";
        group = options.group;
      }) cfg.certs;
    };
    systemd.services = lib.mapAttrs' (
      name: _:
      lib.nameValuePair "acme-order-renew-${name}" {
        environment.LEGO_DISABLE_CNAME_SUPPORT = "true";
      }
    ) cfg.certs;
  };
}
