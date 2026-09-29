{
  globals,
  lib,
  osConfig ? null,
  systemType,
  ...
}:
let
  isSystemModule = systemType != "Standalone" && osConfig == null;
  secrets = import ./secrets.nix;
  presentSecrets = lib.filterAttrs (name: _: builtins.pathExists ./${name}) secrets;
  hostSecrets = lib.filterAttrs (
    name: attrs:
    globals.hostName == null || !(attrs ? hosts) || builtins.elem globals.hostName attrs.hosts
  ) presentSecrets;
in
{
  age.secrets = builtins.mapAttrs (
    name: attrs:
    {
      file = ./${name};
      mode = attrs.mode or "0400";
    }
    // lib.optionalAttrs isSystemModule {
      group = attrs.group or "root";
      owner = attrs.owner or "root";
    }
  ) hostSecrets;
}
