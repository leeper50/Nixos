{ plasma-manager, ... }:
{
  imports = [
    plasma-manager.homeModules.plasma-manager
  ];
  programs.plasma = {
    enable = true;
    workspace = {
      iconTheme = "Papirus-Dark";
    };
  };
}
