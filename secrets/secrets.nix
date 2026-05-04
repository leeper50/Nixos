let
  gk55 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJGHhitPnvUzImWRb80A31LvBoQru3BXUMb+lgDUKkE0 root@nixos";
  nas = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIISsnpyceiNgLPCVpZiCuZ06a9Zpl3kUKmCCqRI6RFn2 root@nas";
  node-1 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBFeYUBJfc4KaXEi4ZU+9iIhGo6d7Q26U0DaDeGlLFu6 root@node-1";
  node-2 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHAXbx862PzPMJZAzGkl+bfghtbWCSONNJf3l+34HCbg root@node-2";
  node-3 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIFWricdYPgzpDg/AEdjw4cUSCBM2LBOP3JexKsn3p41 root@node-3";
  personal = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIxiUaRCIxik4Ptw9JUm/vJiUcKMxEPuGpdf5CZWGZ1Z Walter-PC";
  k3_swarm_keys = [
    node-1
    node-2
    node-3
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
