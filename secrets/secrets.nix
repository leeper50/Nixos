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
  "mumble_server_password.age" = {
    publicKeys = [
      personal
      racknerd
    ];
    hosts = [ "racknerd" ];
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
