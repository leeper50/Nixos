{
  config,
  globals,
  lib,
  pkgs,
  secrets,
  ...
}:
let
  cfg = config.local.authelia;
  pass = config.age.secrets;

  users = {
    walter = {
      displayname = globals.fullName;
      email = globals.primaryEmail;
      groups = [ "admins" ];
    };
  };
  hashSecret = name: "authelia_password_hash_${name}.age";
  hashVar = name: "hash_${lib.replaceStrings [ "-" ] [ "_" ] name}";
  usersDir = "/run/authelia-main-users";
  usersFile = "${usersDir}/users.yml";

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
    domain = lib.mkOption {
      default = config.local.caddy.domain;
      type = lib.types.str;
    };
    enable = lib.mkEnableOption "Authelia (OIDC provider) with a declarative users file";
  };
  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      age.secrets = {
        "authelia_jwt_secret.age".file = "${secrets}/authelia_jwt_secret.age";
        "authelia_oidc_hmac_secret.age".file = "${secrets}/authelia_oidc_hmac_secret.age";
        "authelia_oidc_issuer_key.age".file = "${secrets}/authelia_oidc_issuer_key.age";
        "authelia_storage_encryption_key.age".file = "${secrets}/authelia_storage_encryption_key.age";
      }
      // lib.mapAttrs' (
        name: _:
        lib.nameValuePair (hashSecret name) {
          file = "${secrets}/${hashSecret name}";
          owner = "authelia-main";
        }
      ) users;
      services.authelia.instances.main = {
        enable = true;
        secrets = {
          jwtSecretFile = pass."authelia_jwt_secret.age".path;
          oidcHmacSecretFile = pass."authelia_oidc_hmac_secret.age".path;
          oidcIssuerPrivateKeyFile = pass."authelia_oidc_issuer_key.age".path;
          storageEncryptionKeyFile = pass."authelia_storage_encryption_key.age".path;
        };
        settings = {
          access_control.default_policy = "one_factor";
          authentication_backend = {
            file.path = usersFile;
            password_change.disable = true;
            password_reset.disable = true;
          };
          identity_providers.oidc.clients =
            mkOidcClient config.services.headscale.enable {
              access_token_signed_response_alg = "none";
              client_id = "headscale";
              client_name = "Headscale";
              client_secret = "$pbkdf2-sha512$310000$bqQR9jguvCA3dHh8twp7Xg$BL/QJrhvx7KUX/tNeC.W4qY6vX88EtCL6DXts4kh3447MYvQz631iYQApPmsh3asn1/DM6ydKXZ9aUahkBhDrA";
              redirect_uris = [ "${config.services.headscale.settings.server_url}/oidc/callback" ];
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
              redirect_uris = [ "${config.services.headplane.settings.server.base_url}/admin/oidc/callback" ];
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
              authelia_url = "https://login.${cfg.domain}";
              domain = cfg.domain;
            }
          ];
          storage.local.path = "/var/lib/authelia-main/db.sqlite3";
        };
      };
      systemd.services = {
        authelia-main.restartTriggers = [ config.systemd.services.authelia-main-users.script ];
        authelia-main-users = {
          before = [ "authelia-main.service" ];
          requiredBy = [ "authelia-main.service" ];
          script = ''
            umask 0077
            ${lib.getExe pkgs.jq} -n \
              ${
                lib.concatMapStringsSep " \\\n  " (
                  name: "--rawfile ${hashVar name} ${pass.${hashSecret name}.path}"
                ) (lib.attrNames users)
              } \
              --argjson users ${lib.escapeShellArg (builtins.toJSON users)} \
              '{ users: ($users | with_entries(.value.password = ($ARGS.named["hash_" + (.key | gsub("-"; "_"))] | rtrimstr("\n")))) }' \
              > ${usersFile}
          '';
          serviceConfig = {
            Group = "authelia-main";
            RemainAfterExit = true;
            RuntimeDirectory = baseNameOf usersDir;
            RuntimeDirectoryMode = "0700";
            Type = "oneshot";
            User = "authelia-main";
          };
        };
      };
    })
    (lib.mkIf (cfg.enable && config.services.caddy.enable) {
      services.caddy.virtualHosts."login.${cfg.domain}" = {
        extraConfig = "reverse_proxy 127.0.0.1:${toString autheliaPort}";
        useACMEHost = cfg.domain;
      };
    })
  ];
}
