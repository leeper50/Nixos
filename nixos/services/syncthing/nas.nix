{ ... }:
{
  imports = [
    ./nixos.nix
  ];

  local.syncthing = {
    folders = {
      "GlobalShare" = {
        enable = true;
        type = "receiveonly";
      };
      "Notes" = {
        enable = true;
        type = "receiveonly";
      };
    };
    home = "/mnt/data/SambaHomes/walter";
  };
}
