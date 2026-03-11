let
  primary = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIxiUaRCIxik4Ptw9JUm/vJiUcKMxEPuGpdf5CZWGZ1Z Walter-PC";
  keys = [
    primary
  ];
in
{
  "user-walter-clear.age".publicKeys = keys;
  "user-walter-hash.age".publicKeys = keys;
}
