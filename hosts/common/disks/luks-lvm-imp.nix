{systemSettings, ...}: {
  # Disko config using luks, lvm, swap, and btrfs subvolumes for use with impermanence module
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/${systemSettings.diskDevice}";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "2G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            luks = {
              size = "100%";
              content = {
                type = "luks";
                name = "crypt";
                extraOpenArgs = [ ];
                settings = {
                  # if you want to use the key for interactive login be sure there is no trailing newline
                  # for example use `echo -n "password" > /tmp/secret.key`
                  allowDiscards = true;
                };
                content = {
                  type = "lvm_pv";
                  vg = "lvm";
                };
              };
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
                  mountpoint = "/persist";
                  mountOptions = ["compress=zstd" "noatime"];
                };
                "swap" = {
                  mountpoint = "/.swap";
                  swap.swapfile.size = systemSettings.swapSize;
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
