{
  modulesPath,
  pkgs,
  ...
}:
{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
  ];
  boot.initrd.availableKernelModules = [
    "ata_piix"
    "uhci_hcd"
    "virtio_pci"
    "virtio_scsi"
    "sd_mod"
    "sr_mod"
  ];
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = true;
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/aa9d260b-84d1-4ffb-b81f-e489cd3aa0e9";
    fsType = "ext4";
  };
  swapDevices = [
    { device = "/dev/disk/by-uuid/d6a62032-d693-445c-9db2-458867d748f8"; }
  ];
}
