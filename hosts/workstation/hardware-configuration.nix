{
  config,
  lib,
  modulesPath,
  pkgs,
  ...
}:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];
  boot.initrd.availableKernelModules = [
    "ahci"
    "nvme"
    "sd_mod"
    "usb_storage"
    "usbhid"
    "xhci_pci"
  ];
  boot.extraModulePackages = [ ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  hardware.display = {
    edid.packages = [
      (pkgs.runCommand "edid-m27q-dp" { } ''
        install -Dm444 ${./m27q-dp.bin} $out/lib/firmware/edid/m27q-dp.bin
      '')
    ];
    outputs."DP-1" = {
      edid = "m27q-dp.bin";
      mode = "2560x1440@120e";
    };
  };
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
