{
  config,
  globals,
  lib,
  osConfig ? null,
  systemType,
  ...
}:
let
  isSystemModule = systemType != "Standalone" && osConfig == null;
  secrets = import ./secrets.nix;
  keys = import ./keys.nix;
  hostKey = if isSystemModule then keys.${globals.hostName} or keys.personal else keys.personal;
  undecryptable = lib.filter (
    name:
    let
      fileName = baseNameOf config.age.secrets.${name}.file;
    in
    secrets ? ${fileName} && !(builtins.elem hostKey secrets.${fileName}.publicKeys)
  ) (builtins.attrNames config.age.secrets);
in
{
  assertions = lib.optional (globals.hostName != null) {
    assertion = undecryptable == [ ];
    message = "${globals.hostName} deploys secrets not encrypted to its key (add it to publicKeys in secrets/secrets.nix and rekey): ${lib.concatStringsSep ", " undecryptable}";
  };
}
