{ ... }:
{
  homebrew = {
    enable = true;
    enableFishIntegration = true;
    brews = [ ];
    casks = [
      "freac"
      "imgbrd-grabber"
      "onlyoffice"
      "parsec"
      "qview"
      "vivaldi"
    ];
  };
}
