let
  gk55 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJGHhitPnvUzImWRb80A31LvBoQru3BXUMb+lgDUKkE0 root@nixos";
  nas = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKF/+u9TUbzAla9ejzsvGGkrLCHTcQ2gN3UJaXKUDlns root@nixos";
  node-1 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFR09vP5ljQEV1guQ+jOAIe3DKNnEzAbRpSf9/m1rc4C root@node-1";
  node-2 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINvE1NTqdE7/ZCv+U25coA5rFxIDVUarbCPt3+1J10Lo root@node-2";
  node-3 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID6RmulzmQsxyfgJlX5leCdgcUCvoHnbbaOHoqOwYlfs root@node-3";
  node-4 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINobVoMCJN2aTgxCLsnSXusiQbx9UZvS7mYgHuVcfjEz root@node-4";
  personal = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIxiUaRCIxik4Ptw9JUm/vJiUcKMxEPuGpdf5CZWGZ1Z Walter-PC";
  k3_swarm_keys = [
    node-1
    node-2
    node-3
    node-4
    personal
  ];
  all_keys = [
    gk55
    nas
  ]
  ++ k3_swarm_keys;
in
{
  "k3s_token.age".publicKeys = all_keys;
  "user_walter_clear.age".publicKeys = all_keys;
  "user_walter_hash.age".publicKeys = all_keys;
}
