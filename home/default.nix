{ agenix, ... }:
{
  imports = [
    agenix.homeManagerModules.default
    ./base
    ./dev
    ./desktop
    ./firefox
    ./games
    ./shell
  ];
}
