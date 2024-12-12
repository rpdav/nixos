{...}: {
  programs.fuse.userAllowOther = true;

  environment.persistence."/persist" = {
    hideMounts = true;
    directories = [
      "/etc/nixos"
      "/etc/secureboot"
      "/etc/ssh"
      "/root/.ssh"
      "/var/lib/fprint"
      "/var/lib/tailscale"
      "/var/log"
      "/var/lib/bluetooth"
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
      "/etc/NIXOS"
      {
        file = "/var/keys/secret_file";
        parentDirectory = {mode = "u=rwx,g=,o=";};
      }
    ];
  };

  security.sudo.extraConfig = ''
    # rollback results in sudo lectures after reboot
    Defaults lecture = never
  '';
}
