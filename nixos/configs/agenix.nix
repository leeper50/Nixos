{ config, lib, ... }:
let
  secrets = import ../../secrets/secrets.nix;
  presentSecrets = lib.filterAttrs (
    name: _: builtins.pathExists (../../secrets + "/${name}")
  ) secrets;
  hostSecrets = lib.filterAttrs (
    name: attrs: !(attrs ? hosts) || builtins.elem config.networking.hostName attrs.hosts
  ) presentSecrets;
in
{
  age.secrets = builtins.mapAttrs (name: attrs: {
    file = ../../secrets/${name};
    owner = attrs.owner or "root";
    group = attrs.group or "root";
    mode = attrs.mode or "0400";
  }) hostSecrets;
}
