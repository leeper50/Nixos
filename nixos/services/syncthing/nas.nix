{ ... }:
{
  imports = [
    ./nixos.nix
  ];

  local.syncthing = {
    home = "/mnt/data/SambaHomes/walter";
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
  };
}
