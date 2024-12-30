{serviceOpts, ...}: {
  programs.fuse.userAllowOther = true;

  environment.persistence."/persist" = {
    hideMounts = true;
    directories = [
      "/etc/nixos"
      "/etc/secureboot"
      "/root/.ssh"
      "/var/lib/fprint"
      "/var/lib/tailscale"
      "/var/log"
      "/var/lib/bluetooth"
      "${serviceOpts.dockerDir}"
#      {
#        directory = "${serviceOpts.dockerDir}";
#        user = "${serviceOpts.dockerUser}";
#	group = "users";
#	mode = "0700";
#      }
      "/var/lib/docker" #should this live here or in docker config?
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
      "/etc/ssh/ssh_host_ed25519_key"
      "/etc/ssh/ssh_host_ed25519_key.pub"
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
