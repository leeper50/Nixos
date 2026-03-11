{ config, pkgs, ... }:
let
  secrets = import ../secrets/secrets.nix;  # adjust path as needed
in
{
  # pull all secrets into the config
  age.secrets = builtins.mapAttrs (name: attrs: {
    file = ./secrets/${name};   # adjust path based on your module location
    owner = attrs.owner or "root";
    group = attrs.group or "root";
    mode = attrs.mode or "0400";
  }) secrets;
}