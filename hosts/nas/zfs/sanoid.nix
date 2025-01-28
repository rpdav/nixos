{...}: {
  services.sanoid = {
    enable = true;
    templates.data = {
      hourly = 24;
      daily = 30;
      monthly = 12;
      yearly = 1;
      autoprune = true;
      autosnap = true;
    };
    templates.backup = {
      hourly = 24;
      daily = 30;
      monthly = 12;
      yearly = 1;
      autoprune = true;
      autosnap = false;
    };
    datasets."storage" = {
      useTemplate = ["data"];
      recursive = true;
    };
    datasets."storage/syncoid" = {
      # syncoid datasets have already been snapshotted - only need prune
      useTemplate = ["backup"];
      recursive = true;
    };
    datasets."docker" = {
      useTemplate = ["data"];
      recursive = true;
    };
    datasets."vms" = {
      useTemplate = ["data"];
      recursive = true;
    };
  };

  # Replicate ssd pools to hdd pool for local backup
  services.syncoid = {
    # Permissions the local `syncoid` user gets to manipulate the local ZFS datasets
    # that are the sources for backups.
    localSourceAllow = [
      "change-key"
      "compression"
      "create"
      "mount"
      "mountpoint"
      "receive"
      "rollback"
      "bookmark"
      "hold"
      "send"
      "snapshot"
      "destroy"
    ];
    # Permissions the local `syncoid` user gets to manipulate local ZFS datasets that
    # are the targets for backups.
    # NOTE: you must ensure the remote syncoid user has similar permissions.
    localTargetAllow = [
      "change-key"
      "compression"
      "create"
      "mount"
      "mountpoint"
      "receive"
      "rollback"
      "bookmark"
      "hold"
      "send"
      "snapshot"
      "destroy"
    ];
    enable = true;
    commands.docker = {
      source = "docker";
      target = "storage/syncoid/docker";
      recursive = true;
    };
    commands.vms = {
      source = "vms";
      target = "storage/syncoid/vms";
      recursive = true;
    };
  };
}
