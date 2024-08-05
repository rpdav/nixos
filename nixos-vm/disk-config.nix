{ lib, ... }:

{
  disko.devices = {
    disk.disk1 = {
      device = lib.mkDefault "/dev/vda";
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            name = "ESP";
            size = "1G";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
            };
          };
          swap = {
            name = "swap";
            size = "4G";
            content = {
              type = "swap";
              resumeDevice = "false";
            };
          };
          root = {
            size = "100%";
            content = {
              type = "btrfs";
              extraArgs = [ "-f" ];
              subvolumes = {
                "rootfs" = {
                  mountpoint = "/";
                };
                "/nix" = {
                  mountpoint = "/nix";
                  mountOptions = [ "compress = zstd" "noatime" ]
                };
                "/persist" = {
                  mountpoint = "/persist";
                  mountOptions = [ "compress = zstd" "noatime" ]
                };
              };
            };
          };
        };
      };
    };
  };
  fileSystems."/persist".neededForBoot = true;
}
