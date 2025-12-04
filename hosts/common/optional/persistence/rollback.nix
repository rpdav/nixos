{
  lib,
  config,
  pkgs,
  ...
}: let
  systemd = config.boot.initrd.systemd.enable;
  script = ''
    echo "making temp directory"
    mkdir /btrfs_tmp
    echo "mounting btrfs drive to temp directory"
    mount /dev/lvm/root /btrfs_tmp
    echo "making new root backup"
    if [[ -e /btrfs_tmp/root ]]; then
        mkdir -p /btrfs_tmp/old_roots
        timestamp=$(date --date="@$(stat -c %Y /btrfs_tmp/root)" "+%Y-%m-%-d_%H:%M:%S")
        mv /btrfs_tmp/root "/btrfs_tmp/old_roots/$timestamp"
    fi

    echo "deleting old root backups"
    delete_subvolume_recursively() {
        IFS=$'\n'
        for i in $(btrfs subvolume list -o "$1" | cut -f 9- -d ' '); do
            delete_subvolume_recursively "/btrfs_tmp/$i"
        done
        btrfs subvolume delete "$1"
    }

    for i in $(find /btrfs_tmp/old_roots/ -maxdepth 1 -mtime +30); do
        delete_subvolume_recursively "$i"
    done

    echo "creating new blank subvolume"
    btrfs subvolume create /btrfs_tmp/root
    umount /btrfs_tmp
  '';
in {
  # Do rollback using postDeviceCommands if initrd.systemd is not in use
  boot.initrd.postDeviceCommands = lib.mkIf (!systemd) (lib.mkAfter script);

  # Use a systemd service otherwise
  boot.initrd.systemd = lib.mkIf systemd {
    initrdBin = with pkgs; [
      util-linux
      #btrfs-progs
      #coreutils
    ];
    services."rollback" = {
      description = "Create a snapshoot of root and then rollback";
      inherit script;
      wantedBy = ["initrd.target"];
      after = ["dev-lvm-root.device"];
      before = ["initrd-switch-root.target"];
      unitConfig.DefaultDependencies = "no";
      serviceConfig = {
        StandardOutput = "journal";
        StandardError = "journal";
        Type = "oneshot";
      };
    };
  };
}
