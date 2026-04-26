let
  gk55 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJGHhitPnvUzImWRb80A31LvBoQru3BXUMb+lgDUKkE0 root@nixos";
  nas = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKF/+u9TUbzAla9ejzsvGGkrLCHTcQ2gN3UJaXKUDlns root@nixos";
  swarm = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEqdihzgtsfoSrS6YVx4LCkPuuTRWV5GWOPbmhWTAhrf root@swarm";
  node-1 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFR09vP5ljQEV1guQ+jOAIe3DKNnEzAbRpSf9/m1rc4C root@node-1";
  node-2 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINvE1NTqdE7/ZCv+U25coA5rFxIDVUarbCPt3+1J10Lo root@node-2";
  node-3 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID6RmulzmQsxyfgJlX5leCdgcUCvoHnbbaOHoqOwYlfs root@node-3";
  personal = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIxiUaRCIxik4Ptw9JUm/vJiUcKMxEPuGpdf5CZWGZ1Z Walter-PC";
  keys = [
    gk55
    nas
    swarm
    node-1
    node-2
    node-3
    personal
  ];
in
{
  "user_walter_clear.age".publicKeys = keys;
  "user_walter_hash.age".publicKeys = keys;
}
