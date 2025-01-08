{
  systemOpts,
  lib,
  inputs,
  ...
}: {
  # Disko config using lvm, optional swap, and btrfs subvolumes for use in the impermanence module
  imports = [inputs.disko.nixosModules.disko];

  disko.devices = {
    disk.main = {
      device = "/dev/${systemOpts.diskDevice}";
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          boot = {
            name = "boot";
            size = "1M";
            type = "EF02";
          };
          ESP = {
            name = "ESP";
            size = "500M";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
            };
          };
          primary = {
            size = "100%";
            content = {
              type = "lvm_pv"; #rollback script assumes lvm is used
              vg = "lvm";
            };
          };
        };
      };
    };
    lvm_vg = {
      lvm = {
        type = "lvm_vg";
        lvs = {
          root = {
            size = "100%FREE";
            content = {
              type = "btrfs";
              extraArgs = ["-f"];
              subvolumes = {
                "root" = {
                  #rollback script assumes root subvol is "root"
                  mountpoint = "/";
                  mountOptions = ["compress=zstd" "noatime"];
                };
                "nix" = {
                  mountpoint = "/nix";
                  mountOptions = ["compress=zstd" "noatime"];
                };
                "persist" = {
                  mountpoint = "${systemOpts.persistVol}";
                  mountOptions = ["compress=zstd" "noatime"];
                };
                "swap" = lib.mkIf systemOpts.swapEnable {
                  mountpoint = "/.swap";
                  swap.swapfile.size = systemOpts.swapSize;
                };
              };
            };
          };
        };
      };
    };
  };
  fileSystems.${systemOpts.persistVol}.neededForBoot = true;
}
