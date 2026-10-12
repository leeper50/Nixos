let
  inherit (import ./keys.nix)
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
    macbook
    nas
    racknerd
    servercheap
  ]
  ++ swarm_keys;
in
{
  "acme_cloudflare.age".publicKeys = all_keys;
  "acme_porkbun.age".publicKeys = all_keys;
  "authelia_jwt_secret.age".publicKeys = [
    personal
    servercheap
  ];
  "authelia_oidc_hmac_secret.age".publicKeys = [
    personal
    servercheap
  ];
  "authelia_oidc_issuer_key.age".publicKeys = [
    personal
    servercheap
  ];
  "authelia_storage_encryption_key.age".publicKeys = [
    personal
    servercheap
  ];
  "beszel_token.age".publicKeys = swarm_keys ++ [
    nas
    racknerd
    servercheap
  ];
  "docker_swarm_token.age".publicKeys = swarm_keys;
  "forgejo_token.age".publicKeys = [
    personal
    servercheap
  ];
  "headplane_cookie_secret.age".publicKeys = [
    personal
    servercheap
  ];
  "headplane_headscale_api_key.age".publicKeys = [
    personal
    servercheap
  ];
  "headplane_oidc_client_secret.age".publicKeys = [
    personal
    servercheap
  ];
  "headscale_oidc_client_secret.age".publicKeys = [
    personal
    servercheap
  ];
  "headscale_preauth_key.age".publicKeys = all_keys;
  "jellyfin_api_key.age".publicKeys = [
    nas
    personal
  ];
  "komodo_admin_password.age".publicKeys = [
    node-1
    personal
  ];
  "komodo_onboarding_key.age".publicKeys = swarm_keys ++ [
    racknerd
    servercheap
  ];
  "lldap_admin_password.age".publicKeys = [
    personal
    servercheap
  ];
  "murmur_environment.age".publicKeys = [
    personal
    racknerd
    servercheap
  ];
  "murmur_superuser_password.age".publicKeys = [
    personal
    racknerd
    servercheap
  ];
  "ntfy_access_token.age".publicKeys = all_keys;
  "ntfy_environment.age".publicKeys = [
    personal
    node-3
  ];
  "postgresql_forgejo.age".publicKeys = swarm_keys ++ [ nas ];
  "postgresql_freshrss.age".publicKeys = swarm_keys ++ [ nas ];
  "postgresql_miniflux.age".publicKeys = swarm_keys ++ [ nas ];
  "postgresql_rxresume.age".publicKeys = swarm_keys ++ [ nas ];
  "redis_rxresume.age".publicKeys = swarm_keys ++ [ nas ];
  "restic_b2_env.age".publicKeys = all_keys;
  "restic_password_file.age".publicKeys = all_keys;
  "restic_rustfs_env.age".publicKeys = all_keys;
  "surge_auth_token.age".publicKeys = [ personal ];
  "tofu_env.age".publicKeys = [ personal ];
  "user_walter_clear.age".publicKeys = all_keys;
  "user_walter_hash.age".publicKeys = all_keys;
  "wifi_home_env.age".publicKeys = [ personal ];
}
