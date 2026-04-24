{ ... }:
{
  homebrew = {
    enable = true;
    enableFishIntegration = true;
    brews = [ ];
    casks = [
      "freac"
      "onlyoffice"
      "parsec"
      "qview"
      "vivaldi"
    ];
  };
}
