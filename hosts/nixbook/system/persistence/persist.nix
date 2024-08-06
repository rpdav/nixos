{ config, lib, secrets, userSettings, ... }:

{
  
  environment.etc = {
    nixos.source = "/persist/etc/nixos";
    NIXOS.source = "/persist/etc/NIXOS";
    adjtime.source = "/persist/etc/adjtime";
  };

  programs.fuse.userAllowOther = true;

  environment.persistence."/persist" = {
    enable = true;  # NB: Defaults to true, not needed
    hideMounts = true;
    directories = [
      "/etc/wireguard"
      "/root/.ssh"
      "/var/lib/tailscale"
      "/var/log"
      "/var/lib/bluetooth"
      "/var/lib/nixos"
      "/var/lib/systemd/coredump"
      "/etc/NetworkManager/system-connections"
      "/var/lib/NetworkManager"
      { directory = "/var/lib/colord"; user = "colord"; group = "colord"; mode = "u=rwx,g=rx,o="; }
#      "/var/lib/sddm" # something to do with KDE
    ];
    files = [
      "/etc/machine-id"
      { file = "/var/keys/secret_file"; parentDirectory = { mode = "u=rwx,g=,o="; }; }
    ];

    ## user persistence is in user/persistence/persist.nix. .config only works in the system config so that's why it's here.here
    users.${userSettings.username} = {
      directories = [
        ".config"
      ];
      files = [
      ];
    };
  };

  security.sudo.extraConfig = ''
    # rollback results in sudo lectures after reboot
    Defaults lecture = never
    '';
    
}
