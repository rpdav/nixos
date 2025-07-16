{
  modulesPath,
  lib,
  configLib,
  pkgs,
  config,
  ...
}: let
  # Generates a list of the keys in ./keys
  pubKeys = lib.filesystem.listFilesRecursive ../common/users/ryan/keys;
  inherit (config) systemOpts;
in {
  imports =
    lib.flatten
    [
      (map configLib.relativeToRoot [
        # core config
        "vars"
        "hosts/common/core"

        # disk config
        "hosts/common/disks/btrfs-imp.nix"

        # optional config
        "hosts/common/optional/backup/remote.nix"
        "hosts/common/optional/persistence"
        "hosts/common/optional/yubikey.nix"
        "hosts/common/optional/docker.nix"

        # services
        "services/common"
        "services/vps"

        # users
        "hosts/common/users/ryan"
      ])

      # host-specific
      ./hardware-configuration.nix
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

  # Variable overrides
  userOpts.primaryUser = "ryan"; #primary user (not necessarily only user)
  systemOpts = {
    swapEnable = true;
    swapSize = "2G";
    diskDevice = "sda";
    gcRetention = "7d";
    impermanent = true;
    gui = false;
  };
  serviceOpts = {
    dockerDir = "/opt/docker";
    proxyDir = "/run/selfhosting/proxy-confs";
  };
  backupOpts = {
    remoteRepo = "/mnt/B2/borg";
    sourcePaths = [systemOpts.persistVol];
    excludeList = [
      # Run `borg help patterns` for guidance on exclusion patterns
      "*/home/*/.git/**" #can be restored from repo
      "*/var/**"
    ];
  };

  # Enable LISH console
  boot.kernelParams = ["console=ttyS0,19200n8"];
  boot.loader.grub.extraConfig = ''
    serial --speed=19200 --unit=0 --word=8 --parity=no --stop=1;
    terminal_input serial;
    terminal_output serial
  '';

  # Allow time for LISH connection delay
  boot.loader.grub.device = "nodev";
  boot.loader.timeout = 10;

  # networking
  networking = {
    hostName = "vps";
    usePredictableInterfaceNames = false; # Linode doesn't use predictable network names
    useDHCP = false; # IP is assigned by Linode statically
    interfaces.eth0.useDHCP = true; # Required for SSH
  };
  services.tailscale.extraUpFlags = ["--accept-routes" "--advertise-exit-node"]; #accept tailscale routes to LAN during reauth.

  # allow root ssh login for rebuilds
  users.users.root = {
    openssh.authorizedKeys.keys = lib.lists.forEach pubKeys (key: builtins.readFile key);
  };

  environment.systemPackages = with pkgs; [
    # Recommended utils per Linode
    inetutils
    mtr
    sysstat
  ];

  # VPS docker directory lives in persistent volume
  environment.persistence.${systemOpts.persistVol} = lib.mkIf systemOpts.impermanent {
    directories = [
      "${config.serviceOpts.dockerDir}"
    ];
  };

  # VPS monitoring
  sops.secrets."linode/longviewAPIKey" = {};
  services.longview = {
    enable = true;
    apiKeyFile = config.sops.secrets."linode/longviewAPIKey".path;
  };

  system.stateVersion = "25.05";
}
