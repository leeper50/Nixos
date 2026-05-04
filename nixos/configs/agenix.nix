{ lib, ... }:
let
  secrets = import ../../secrets/secrets.nix;
  # Filter out secrets whose .age files don't exist yet so the flake evaluates
  # cleanly while a secret is declared in secrets.nix but not yet created.
  presentSecrets = lib.filterAttrs
    (name: _: builtins.pathExists (../../secrets + "/${name}"))
    secrets;
in
{
  age.secrets = builtins.mapAttrs (name: attrs: {
    file = ../../secrets/${name};
    owner = attrs.owner or "root";
    group = attrs.group or "root";
    mode = attrs.mode or "0400";
  }) presentSecrets;
}
