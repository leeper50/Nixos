{
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/sda";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              content = {
                format = "vfat";
                mountpoint = "/boot";
                type = "filesystem";
              };
              size = "512M";
              type = "EF00";
            };
            swap = {
              content.type = "swap";
              size = "4G";
            };
            root = {
              content = {
                format = "xfs";
                mountpoint = "/";
                type = "filesystem";
              };
              size = "100%";
            };
          };
        };
      };
    };
  };
}
