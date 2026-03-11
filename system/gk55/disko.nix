{ ... }:
{
  disko.devices = {
      sdb = {
        type = "disk";
        device = "/dev/sdb";
        content = {
          type = "gpt";
          partitions = {
            storage = {
              size = "100%";
              content = {
                type = "btrfs";
                extraArgs = [ "-f" "-d" "raid1" "-m" "raid1" "/dev/sdc1" ];
                mountpoint = "/mnt/data";
              };
            };
          };
        };
      };
      sdc = {
        type = "disk";
        device = "/dev/sdc";
        content = {
          type = "gpt";
          partitions = {
            storage = {
              size = "100%";
            };
          };
        };
      };
    };
  };
}
