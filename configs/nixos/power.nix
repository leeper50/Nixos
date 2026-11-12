{ lib, ... }:
{
  powerManagement = {
    cpuFreqGovernor = "powersave";
    enable = true;
    powertop.enable = lib.mkDefault true;
  };
}
