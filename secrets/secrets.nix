let
  gk55 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJGHhitPnvUzImWRb80A31LvBoQru3BXUMb+lgDUKkE0 root@nixos";
  komodo = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPieb/L9L+lfCvkA2nXaRZmvwbByskxXPLMV8PI4hmxG root@komodo";
  macbook = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAmnjjOxA1m5W7WqeD26WTliaDJYcsUr8vN/yfk8/3x4";
  nas = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIISsnpyceiNgLPCVpZiCuZ06a9Zpl3kUKmCCqRI6RFn2 root@nas";
  node-1 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMOWw3itt6X+guXpUY1m5M2inL0Zs+Fs0nTrUOqDwZ/c root@node-1";
  node-2 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF99jYxJYq1frbpyemmxb7+G4+N0Q0XF77sNDiQcphc4 root@node-2";
  node-3 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMqG4JLWJ+lFKdOqTnY/gNHMoYLx82NjaTmwE7Lo1tJG root@node-3";
  personal = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIxiUaRCIxik4Ptw9JUm/vJiUcKMxEPuGpdf5CZWGZ1Z Walter-PC";
  racknerd = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJOG4Vck8uHGDMltzh1/UYFh9vEOz2q7t0Xo6MRlvxDA root@racknerd-8bb595e";
  servercheap = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH3Kl98RyC+da66FPzOEmYhIr+sAoOevfF4tkXruWAoE root@nixos";
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
      "nas"
      "node-1"
      "node-2"
      "node-3"
      "racknerd"
      "servercheap"
    ];
  };
  "k3s_token.age" = {
    publicKeys = swarm_keys;
    hosts = [
      "node-1"
      "node-2"
      "node-3"
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
      "nas"
      "node-1"
      "node-2"
      "node-3"
      "workstation"
    ];
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
