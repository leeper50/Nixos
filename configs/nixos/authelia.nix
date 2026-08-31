{
  config,
  globals,
  lib,
  ...
}:
let
  cfg = config.local.authelia;
  pass = config.age.secrets;
  authDomain = "auth.${globals.domain}";
  lldapDomain = "lldap.${globals.domain}";
  headscaleDomain = "headscale.${globals.domain}";
  baseDn = lib.concatMapStringsSep "," (part: "dc=${part}") (lib.splitString "." globals.domain);
  bindDn = "uid=admin,ou=people,${baseDn}";
  autheliaPort = 9092;
in
{
  options.local.authelia = {
    enable = lib.mkEnableOption "Authelia (OIDC provider) backed by LLDAP";
    headscaleOidcClientSecretHash = lib.mkOption {
      type = lib.types.str;
      default = "";
    };
    headplaneOidcClientSecretHash = lib.mkOption {
      type = lib.types.str;
      default = "";
    };
  };
  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.headscaleOidcClientSecretHash != "";
        message = "Must set local.authelia.headscaleOidcClientSecretHash once you've generated it (see the option's source comment).";
      }
      {
        assertion = cfg.headplaneOidcClientSecretHash != "";
        message = "Must set local.authelia.headplaneOidcClientSecretHash once you've generated it (see the option's source comment).";
      }
    ];
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
    systemd.services.lldap.serviceConfig = {
      DynamicUser = lib.mkForce false;
      Group = "lldap";
      User = "lldap";
    };
    users.users.lldap = {
      extraGroups = [ "ldap-bind-secret" ];
      group = "lldap";
      isSystemUser = true;
    };
    users.groups.lldap = { };
    users.groups.ldap-bind-secret = { };
    services.nginx.virtualHosts.${lldapDomain} = {
      forceSSL = true;
      locations."/".proxyPass = "http://127.0.0.1:17170";
      useACMEHost = globals.domain;
    };
    users.users.authelia-headscale.extraGroups = [ "ldap-bind-secret" ];
    systemd.services.authelia-headscale = {
      after = [ "lldap.service" ];
      wants = [ "lldap.service" ];
    };
    services.authelia.instances.headscale = {
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
        identity_providers.oidc.clients = [
          {
            access_token_signed_response_alg = "none";
            authorization_policy = "one_factor";
            client_id = "headscale";
            client_name = "Headscale";
            client_secret = cfg.headscaleOidcClientSecretHash;
            grant_types = [ "authorization_code" ];
            pkce_challenge_method = "S256";
            public = false;
            redirect_uris = [ "https://${headscaleDomain}/oidc/callback" ];
            require_pkce = true;
            response_types = [ "code" ];
            scopes = [
              "openid"
              "profile"
              "email"
              "groups"
            ];
            token_endpoint_auth_method = "client_secret_basic";
            userinfo_signed_response_alg = "none";
          }
          {
            authorization_policy = "one_factor";
            client_id = "headplane";
            client_name = "Headplane";
            client_secret = cfg.headplaneOidcClientSecretHash;
            grant_types = [ "authorization_code" ];
            pkce_challenge_method = "S256";
            public = false;
            redirect_uris = [ "https://${headscaleDomain}/admin/oidc/callback" ];
            require_pkce = true;
            response_types = [ "code" ];
            scopes = [
              "openid"
              "email"
              "profile"
            ];
            token_endpoint_auth_method = "client_secret_basic";
          }
        ];
        log.level = "info";
        notifier = {
          disable_startup_check = false;
          filesystem.filename = "/var/lib/authelia-headscale/notification.txt";
        };
        server.address = "tcp://127.0.0.1:${toString autheliaPort}/";
        session.cookies = [
          {
            authelia_url = "https://${authDomain}";
            domain = globals.domain;
          }
        ];
        storage.local.path = "/var/lib/authelia-headscale/db.sqlite3";
      };
    };
    services.nginx.virtualHosts.${authDomain} = {
      forceSSL = true;
      locations."/".proxyPass = "http://127.0.0.1:${toString autheliaPort}";
      useACMEHost = globals.domain;
    };
  };
}
