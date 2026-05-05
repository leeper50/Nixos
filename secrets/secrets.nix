let
  gk55 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJGHhitPnvUzImWRb80A31LvBoQru3BXUMb+lgDUKkE0 root@nixos";
  nas = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIISsnpyceiNgLPCVpZiCuZ06a9Zpl3kUKmCCqRI6RFn2 root@nas";
  node-1 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMOWw3itt6X+guXpUY1m5M2inL0Zs+Fs0nTrUOqDwZ/c root@node-1";
  node-2 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF99jYxJYq1frbpyemmxb7+G4+N0Q0XF77sNDiQcphc4 root@node-2";
  node-3 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMqG4JLWJ+lFKdOqTnY/gNHMoYLx82NjaTmwE7Lo1tJG root@node-3";
  personal = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIxiUaRCIxik4Ptw9JUm/vJiUcKMxEPuGpdf5CZWGZ1Z Walter-PC";
  swarm_keys = [
    node-1
    node-2
    node-3
    personal
  ];
  all_keys = [
    gk55
    nas
  ]
  ++ swarm_keys;
in
{
  "portainer_license.age" = {
    publicKeys = [
      node-1
      personal
    ];
    hosts = [ "node-1" ];
  };
  "swarm_token.age" = {
    publicKeys = swarm_keys;
    hosts = [
      "node-1"
      "node-2"
      "node-3"
    ];
  };
  "user_walter_clear.age".publicKeys = all_keys;
  "user_walter_hash.age".publicKeys = all_keys;
}
