let
  server = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJGHhitPnvUzImWRb80A31LvBoQru3BXUMb+lgDUKkE0 root@nixos";
  keys = [
    server
  ];
in
{
  "user_walter_clear.age".publicKeys = keys;
  "user_walter_hash.age".publicKeys = keys;
}
