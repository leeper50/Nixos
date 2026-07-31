{
  config,
  lib,
  modulesPath,
  ...
}:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];
  boot.initrd.availableKernelModules = [
    "ahci"
    "rtsx_usb_sdmmc"
    "sd_mod"
    "sdhci_pci"
    "usb_storage"
    "usbhid"
    "xhci_pci"
  ];
  boot.extraModulePackages = [ ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/e400bf7f-cf5b-41c0-a67d-a73e64d5ec14";
    fsType = "ext4";
  };
  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/FE68-EFB0";
    fsType = "vfat";
    options = [
      "dmask=0077"
      "fmask=0077"
    ];
  };
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  swapDevices = [
    { device = "/dev/disk/by-uuid/0a18a52a-9647-4f63-afe7-0e5559efbda3"; }
  ];
}
