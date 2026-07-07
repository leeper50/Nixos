{ ... }:
{
  imports = [
    ./nixos.nix
  ];

  local.syncthing = {
    folders = {
      "FreeTube" = {
        enable = true;
        type = "receiveonly";
      };
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
