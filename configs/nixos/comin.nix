{
  comin,
  config,
  lib,
  ...
}:
let
  cfg = config.local.comin;
in
{
  imports = [ comin.nixosModules.comin ];
  options.local.comin = {
    enable = lib.mkEnableOption "comin GitOps agent";
  };
  config = lib.mkIf cfg.enable {
    services.comin = {
      enable = true;
      remotes = [
        {
          name = "origin";
          url = "https://fj.dellhplaptop.xyz/wleeper13/Nixos.git";
          branches.main.name = "main";
        }
      ];
    };
  };
}
