{
  lib,
  config,
  pkgs,
  ...
}: let
  systemd = config.boot.initrd.systemd.enable;
  script = ''
    mkdir /btrfs_tmp
    mount /dev/lvm/root /btrfs_tmp
    if [[ -e /btrfs_tmp/root ]]; then
        mkdir -p /btrfs_tmp/old_roots
        timestamp=$(date --date="@$(stat -c %Y /btrfs_tmp/root)" "+%Y-%m-%-d_%H:%M:%S")
        mv /btrfs_tmp/root "/btrfs_tmp/old_roots/$timestamp"
    fi

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

    btrfs subvolume create /btrfs_tmp/root
    umount /btrfs_tmp
  '';
in {
  # Do rollback using postDeviceCommands if initrd.systemd is not in use
  boot.initrd.postDeviceCommands = lib.mkIf (!systemd) (lib.mkAfter script);

  # Use a systemd service otherwise
  boot.initrd.systemd.services."rollback" = lib.mkIf systemd {
    description = "Create a snapshoot of root and then rollback";
    script = ''
      touch /home/ryan/rollback-script-file
      echo "this is when the rollback script ran"
    '';
    #inherit script;
    wantedBy = ["initrd.target"];
    after = ["systemd-cryptsetup@crypt.service"];
    before = ["sysroot.mount"];
    unitConfig.DefaultDependencies = "no";
    path = with pkgs; [
      btrfs-progs
      coreutils
    ];
    serviceConfig.Type = "oneshot";
  };
}
