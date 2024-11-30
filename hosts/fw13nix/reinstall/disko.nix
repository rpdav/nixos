{...}: {
  # Disko config using luks, lvm, swap, and btrfs subvolumes for use with impermanence module
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/nvme0n1"; # change to target device
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
                  swap.swapfile.size = "16G"; #change this to desired swap size
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
