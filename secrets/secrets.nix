let
  email = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKbDcD3eXAYp+ra3OXFLEDABbvVcBpY5yHEv9JULMBdW wleeper13@outlook.com";
  primary = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIxiUaRCIxik4Ptw9JUm/vJiUcKMxEPuGpdf5CZWGZ1Z Walter-PC";
  keys = [ email primary ];
in
{
  "secrets/user-walter-clear.age".publicKeys = keys;
  "secrets/user-walter-hash.age".publicKeys = keys;
}
