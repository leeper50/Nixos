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
  boot.extraModulePackages = [ ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "virtio_balloon" ];
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
