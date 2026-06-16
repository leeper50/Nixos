{
  config,
  lib,
  osConfig ? null,
  systemType,
  hostName ? null,
  ...
}:
let
  resolvedHostName =
    if systemType == "Standalone" then
      hostName
    else if osConfig != null then
      osConfig.networking.hostName
    else
      config.networking.hostName;
  isSystemModule = systemType != "Standalone" && osConfig == null;
  secrets = import ./secrets.nix;
  presentSecrets = lib.filterAttrs (name: _: builtins.pathExists (./${name})) secrets;
  hostSecrets = lib.filterAttrs (
    name: attrs:
    resolvedHostName == null || !(attrs ? hosts) || builtins.elem resolvedHostName attrs.hosts
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
      owner = attrs.owner or "root";
      group = attrs.group or "root";
    }
  ) hostSecrets;
}
