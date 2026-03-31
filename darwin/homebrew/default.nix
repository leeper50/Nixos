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
      "surge"
      "qview"
      "vivaldi"
    ];
  };
}
