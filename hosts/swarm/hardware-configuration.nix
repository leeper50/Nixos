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
  boot.kernelModules = [ "nfsv4" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/4d54bf3c-d3a8-4365-89dc-b8aef81bbe3f";
    fsType = "ext4";
  };

  swapDevices = [
    { device = "/dev/disk/by-uuid/6806cc8f-b956-419b-91f9-4fc41d61291f"; }
  ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
