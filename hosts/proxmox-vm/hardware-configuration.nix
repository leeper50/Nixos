{
  lib,
  modulesPath,
  ...
}:
{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
  ];
  boot.initrd.availableKernelModules = [
    "ata_piix"
    "sd_mod"
    "sr_mod"
    "uhci_hcd"
    "virtio_net"
    "virtio_pci"
    "virtio_scsi"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "virtio_balloon" ];
  boot.extraModulePackages = [ ];
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
