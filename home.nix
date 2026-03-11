{ ... }:
{
  home = {
    shell.enableFishIntegration = true;
    shellAliases = {
      "hm" = "home-manager --flake /etc/nixos.#$(hostname)";
      "update" = "sudo git pull && sudo nixos-rebuild switch";
      "try" = "sudo git pull && sudo nixos-rebuild test";
    };
    stateVersion = "25.11";
    username = "walter";
  };
  programs = {
    bat.enable = true;
    eza = {
      enable = true;
      git = true;
      icons = "always";
    };
    fastfetch.enable = true;
    htop.enable = true;
    git = {
      enable = true;
      lfs.enable = true;
      settings = {
        core.autocrlf = false;
        init.defaultBranch = "main";
        user = {
          email = "wleeper13@outlook.com";
          name = "Walter Leeper";
        };
      };
    };
    fish.enable = true;
    ripgrep.enable = true;
  };
  programs.home-manager.enable = true;
}
