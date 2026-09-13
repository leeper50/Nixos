let
  inherit (import ./keys.nix)
    gk55
    komodo
    macbook
    nas
    node-1
    node-2
    node-3
    personal
    racknerd
    servercheap
    ;
  swarm_keys = [
    node-1
    node-2
    node-3
    personal
  ];
  all_keys = [
    gk55
    komodo
    macbook
    nas
    racknerd
    servercheap
  ]
  ++ swarm_keys;
in
{
  "acme_cloudflare.age" = {
    group = "acme";
    owner = "acme";
    publicKeys = [
      personal
      servercheap
    ];
    hosts = [ "servercheap" ];
  };
  "acme_porkbun.age" = {
    group = "acme";
    owner = "acme";
    publicKeys = [
      personal
      racknerd
    ];
    hosts = [ "racknerd" ];
  };
  "authelia_jwt_secret.age" = {
    publicKeys = [
      personal
      servercheap
    ];
    hosts = [ "servercheap" ];
  };
  "authelia_oidc_hmac_secret.age" = {
    publicKeys = [
      personal
      servercheap
    ];
    hosts = [ "servercheap" ];
  };
  "authelia_oidc_issuer_key.age" = {
    publicKeys = [
      personal
      servercheap
    ];
    hosts = [ "servercheap" ];
  };
  "authelia_storage_encryption_key.age" = {
    publicKeys = [
      personal
      servercheap
    ];
    hosts = [ "servercheap" ];
  };
  "beszel_token.age" = {
    group = "992";
    mode = "0444";
    publicKeys = swarm_keys ++ [
      komodo
      nas
      racknerd
      servercheap
    ];
    hosts = [
      "komodo"
      "laptop"
      "nas"
      "node-1"
      "node-2"
      "node-3"
      "racknerd"
      "servercheap"
    ];
  };
  "docker_swarm_token.age" = {
    publicKeys = swarm_keys;
    hosts = [
      "node-1"
      "node-2"
      "node-3"
    ];
  };
  "forgejo_token.age" = {
    group = "forgejo-runner-podman";
    owner = "forgejo-runner-podman";
    publicKeys = [
      personal
      servercheap
    ];
    hosts = [ ];
  };
  "headplane_cookie_secret.age" = {
    group = "headscale";
    owner = "headscale";
    publicKeys = [
      personal
      servercheap
    ];
    hosts = [ "servercheap" ];
  };
  "headplane_headscale_api_key.age" = {
    group = "headscale";
    owner = "headscale";
    publicKeys = [
      personal
      servercheap
    ];
    hosts = [ "servercheap" ];
  };
  "headplane_oidc_client_secret.age" = {
    group = "headscale";
    owner = "headscale";
    publicKeys = [
      personal
      servercheap
    ];
    hosts = [ "servercheap" ];
  };
  "headscale_oidc_client_secret.age" = {
    group = "headscale";
    owner = "headscale";
    publicKeys = [
      personal
      servercheap
    ];
    hosts = [ "servercheap" ];
  };
  "headscale_preauth_key.age" = {
    publicKeys = all_keys;
  };
  "jellyfin_api_key.age" = {
    publicKeys = [
      nas
      personal
    ];
    hosts = [ "nas" ];
  };
  "komodo_admin_password.age" = {
    publicKeys = [
      komodo
      node-1
      personal
    ];
    hosts = [
      "komodo"
      "node-1"
    ];
  };
  "komodo_onboarding_key.age" = {
    publicKeys = swarm_keys ++ [
      komodo
      racknerd
      servercheap
    ];
    hosts = [
      "komodo"
      "node-1"
      "node-2"
      "node-3"
      "racknerd"
      "servercheap"
    ];
  };
  "lldap_admin_password.age" = {
    group = "ldap-bind-secret";
    mode = "0440";
    owner = "lldap";
    publicKeys = [
      personal
      servercheap
    ];
    hosts = [ "servercheap" ];
  };
  "murmur_environment.age" = {
    publicKeys = [
      personal
      racknerd
      servercheap
    ];
    hosts = [
      "racknerd"
      "servercheap"
    ];
  };
  "murmur_superuser_password.age" = {
    publicKeys = [
      personal
      racknerd
      servercheap
    ];
    hosts = [
      "racknerd"
      "servercheap"
    ];
  };
  "postgresql_forgejo.age" = {
    publicKeys = swarm_keys ++ [ nas ];
    hosts = [
      "nas"
      "node-1"
      "node-2"
      "node-3"
    ];
  };
  "postgresql_freshrss.age" = {
    publicKeys = swarm_keys ++ [ nas ];
    hosts = [
      "nas"
      "node-1"
      "node-2"
      "node-3"
    ];
  };
  "postgresql_rxresume.age" = {
    publicKeys = swarm_keys ++ [ nas ];
    hosts = [
      "nas"
      "node-1"
      "node-2"
      "node-3"
    ];
  };
  "redis_rxresume.age" = {
    publicKeys = swarm_keys ++ [ nas ];
    hosts = [
      "nas"
      "node-1"
      "node-2"
      "node-3"
    ];
  };
  "restic_b2_env.age" = {
    group = "1000";
    owner = "1000";
    publicKeys = all_keys;
    hosts = [
      "komodo"
      "laptop"
      "macbook"
      "nas"
      "node-1"
      "node-2"
      "node-3"
      "workstation"
    ];
  };
  "restic_rustfs_env.age" = {
    group = "1000";
    owner = "1000";
    publicKeys = all_keys;
    hosts = [
      "komodo"
      "laptop"
      "macbook"
      "nas"
      "node-1"
      "node-2"
      "node-3"
      "workstation"
    ];
  };
  "restic_password_file.age" = {
    group = "1000";
    owner = "1000";
    publicKeys = all_keys;
  };
  "surge_auth_token.age" = {
    group = "1000";
    owner = "1000";
    publicKeys = [ personal ];
    hosts = [
      "laptop"
      "workstation"
    ];
  };
  "user_walter_clear.age" = {
    group = "1000";
    owner = "1000";
    publicKeys = all_keys;
  };
  "user_walter_hash.age" = {
    group = "1000";
    owner = "1000";
    publicKeys = all_keys;
  };
}
