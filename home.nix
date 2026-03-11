{ pkgs, ... }:
{
  home = {
    enableFishIntegration = true;
    shellAliases = {
      "hm" = "home-manager --flake /etc/nixos.#$(hostname)";
      "switch" = "sudo nixos-rebuild switch";
      "test" = "sudo nixos-rebuild test";
    };
    stateVersion = "25.11";
    username = "admin";
  };
  programs = {
    bat.enable = true;
    eza = {
      enable = true;
      git = true;
      icons = "always";
    };
    fish.enable = true;
    ripgrep.enable = true;
  };
  programs.home-manager.enable = true;
}
