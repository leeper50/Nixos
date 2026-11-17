{ agenix, secrets, ... }:
{
  imports = [
    ../../configs/home/gui.nix
    ../../configs/home/syncthing.nix
    "${secrets}/default.nix"
    agenix.homeManagerModules.default
  ];
  local = {
    browsers = {
      chromium.enable = false;
      firefox.enable = true;
      librewolf.enable = true;
    };
    syncthing = {
      enable = true;
      home = "/Users/walter";
    };
  };
}
