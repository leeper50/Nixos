{ ... }:
{
  nix.optimise.automatic = true;
  nix.optimise.dates = [ "03:45" ];
  nix.settings.auto-optimise-store = true;
  nix.gc = {
    automatic = true;
    # dates = "weekly";
    options = "--delete-older-than 7d";
  };
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
}
