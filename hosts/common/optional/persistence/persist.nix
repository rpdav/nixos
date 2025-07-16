{config, ...}: {
  programs.fuse.userAllowOther = true;

  environment.persistence.${config.systemOpts.persistVol} = {
    hideMounts = true;
    directories = [
      "/var/log"
      "/var/lib/nixos"
      "/var/lib/systemd/coredump"
      "/etc/NetworkManager/system-connections"
      "/var/lib/NetworkManager"
      {
        directory = "/var/lib/colord";
        user = "colord";
        group = "colord";
        mode = "u=rwx,g=rx,o=";
      }
    ];
    files = [
      "/etc/adjtime"
      "/etc/machine-id"
    ];
  };

  security.sudo.extraConfig = ''
    # rollback results in sudo lectures after reboot
    Defaults lecture = never
  '';
}
