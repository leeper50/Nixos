{
  config,
  globals,
  lib,
  ...
}:
let
  cfg = config.local.authelia;
  pass = config.age.secrets;

  authDomain = "login.${globals.domain}";
  lldapDomain = "ld.${globals.domain}";
  headscaleDomain = "hd.${globals.domain}";
  baseDn = lib.concatMapStringsSep "," (part: "dc=${part}") (lib.splitString "." globals.domain);
  bindDn = "uid=admin,ou=people,${baseDn}";

  autheliaPort = 9091;
  commonOidcClient = {
    authorization_policy = "one_factor";
    grant_types = [ "authorization_code" ];
    pkce_challenge_method = "S256";
    public = false;
    require_pkce = true;
    response_types = [ "code" ];
    token_endpoint_auth_method = "client_secret_basic";
  };
  mkOidcClient = enable: extra: lib.optional enable (commonOidcClient // extra);
in
{
  options.local.authelia = {
    enable = lib.mkEnableOption "Authelia (OIDC provider) backed by LLDAP";
  };
  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      services.authelia.instances.main = {
        enable = true;
        secrets = {
          jwtSecretFile = pass."authelia_jwt_secret.age".path;
          oidcHmacSecretFile = pass."authelia_oidc_hmac_secret.age".path;
          oidcIssuerPrivateKeyFile = pass."authelia_oidc_issuer_key.age".path;
          storageEncryptionKeyFile = pass."authelia_storage_encryption_key.age".path;
        };
        environmentVariables = {
          AUTHELIA_AUTHENTICATION_BACKEND_LDAP_PASSWORD_FILE = pass."lldap_admin_password.age".path;
        };
        settings = {
          access_control.default_policy = "one_factor";
          authentication_backend.ldap = {
            address = "ldap://127.0.0.1:3890";
            base_dn = baseDn;
            implementation = "lldap";
            user = bindDn;
          };
          identity_providers.oidc.clients =
            mkOidcClient config.services.headscale.enable {
              access_token_signed_response_alg = "none";
              client_id = "headscale";
              client_name = "Headscale";
              client_secret = "$pbkdf2-sha512$310000$bqQR9jguvCA3dHh8twp7Xg$BL/QJrhvx7KUX/tNeC.W4qY6vX88EtCL6DXts4kh3447MYvQz631iYQApPmsh3asn1/DM6ydKXZ9aUahkBhDrA";
              redirect_uris = [ "https://${headscaleDomain}/oidc/callback" ];
              scopes = [
                "openid"
                "profile"
                "email"
                "groups"
              ];
              userinfo_signed_response_alg = "none";
            }
            ++ mkOidcClient config.services.headplane.enable {
              client_id = "headplane";
              client_name = "Headplane";
              client_secret = "$pbkdf2-sha512$310000$hPEHI5nF1jxjuq2hraFgsg$SAnFIc.C4YY0Nq3wUPgapva76X4j2J7bGlL4svCejLHEYRVyDh7u7KevS3yyH8e0fJszj5jAWOiJ/xaDC2sRTA";
              redirect_uris = [ "https://${headscaleDomain}/admin/oidc/callback" ];
              scopes = [
                "openid"
                "email"
                "profile"
              ];
            };
          log.level = "info";
          notifier = {
            disable_startup_check = false;
            filesystem.filename = "/var/lib/authelia-main/notification.txt";
          };
          server = {
            address = "tcp://127.0.0.1:${toString autheliaPort}/";
            endpoints.authz."forward-auth".implementation = "ForwardAuth";
          };
          session.cookies = [
            {
              authelia_url = "https://${authDomain}";
              domain = globals.domain;
            }
          ];
          storage.local.path = "/var/lib/authelia-main/db.sqlite3";
        };
      };
      services.lldap = {
        enable = true;
        settings = {
          force_ldap_user_pass_reset = "always";
          http_host = "127.0.0.1";
          http_url = "https://${lldapDomain}";
          ldap_base_dn = baseDn;
          ldap_host = "127.0.0.1";
          ldap_user_email = "bojenkins@mailbox.org";
          ldap_user_pass_file = pass."lldap_admin_password.age".path;
        };
      };
      systemd.services = {
        authelia-main = {
          after = [ "lldap.service" ];
          wants = [ "lldap.service" ];
        };
        lldap.serviceConfig = {
          DynamicUser = lib.mkForce false;
          Group = "lldap";
          User = "lldap";
        };
      };
      users = {
        users.lldap = {
          extraGroups = [ "ldap-bind-secret" ];
          group = "lldap";
          isSystemUser = true;
        };
        groups = {
          lldap = { };
          ldap-bind-secret = { };
        };
        users.authelia-main.extraGroups = [ "ldap-bind-secret" ];
      };
    })
    (lib.mkIf (cfg.enable && config.services.caddy.enable) {
      services.caddy.virtualHosts.${authDomain} = {
        extraConfig = "reverse_proxy 127.0.0.1:${toString autheliaPort}";
        useACMEHost = globals.domain;
      };
      services.caddy.virtualHosts.${lldapDomain} = {
        extraConfig = "reverse_proxy 127.0.0.1:${toString config.services.lldap.settings.http_port}";
        useACMEHost = globals.domain;
      };
    })
  ];
}
