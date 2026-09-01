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
  "cloudflare_dns_api_token.age" = {
    group = "acme";
    owner = "acme";
    publicKeys = [
      personal
      servercheap
    ];
    hosts = [ "servercheap" ];
  };
  "forgejo_token.age" = {
    group = "forgejo-runner-podman";
    owner = "forgejo-runner-podman";
    publicKeys = [
      personal
      servercheap
    ];
    hosts = [ "servercheap" ];
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
  "mumble_environment.age" = {
    publicKeys = [
      personal
      racknerd
    ];
    hosts = [ "racknerd" ];
  };
  "mumble_superuser_password.age" = {
    publicKeys = [
      personal
      racknerd
    ];
    hosts = [ "racknerd" ];
  };
  "porkbun_dns_api_token.age" = {
    group = "acme";
    owner = "acme";
    publicKeys = [
      personal
      servercheap
    ];
    hosts = [ "servercheap" ];
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
  "headscale_preauth_key.age" = {
    publicKeys = all_keys;
  };
  "swarm_token.age" = {
    publicKeys = swarm_keys;
    hosts = [
      "node-1"
      "node-2"
      "node-3"
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
