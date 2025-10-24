{
  modulesPath,
  lib,
  pkgs,
  config,
  configLib,
  ...
}: let
  inherit (config.systemOpts) persistVol impermanent;
  # Generates a list of the keys in primary user's directory in this repo
  pubKeys = lib.filesystem.listFilesRecursive ../common/users/ryan/keys;
in {
  imports =
    lib.flatten
    [
      (map configLib.relativeToRoot [
        # core config
        "vars"
        "hosts/common/core"

        # disk config
        "hosts/common/disks/luks-lvm-imp.nix"

        # optional config
        "hosts/common/optional/backup"
        "hosts/common/optional/docker.nix"
        "hosts/common/optional/persistence"
        "hosts/common/optional/ssh-unlock.nix"
        "hosts/common/optional/steam.nix"
        "hosts/common/optional/virtualization"
        "hosts/common/optional/wm/gnome.nix"
        "hosts/common/optional/yubikey.nix"

        # services
        "services/common"
        "services/nas"

        # users
        "hosts/common/users/ryan"
      ])

      # host-specific
      ./nvidia.nix
      ./win-vm
      ./hardware-configuration.nix
      ./zfs
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

  # Variable overrides
  userOpts = {
    theme = lib.mkForce "mountain"; #override default in hosts/common/ryan/default.nix
  };
  systemOpts = {
    primaryUser = "ryan"; #primary user (not necessarily only user)
    swapEnable = true;
    diskDevice = "nvme1n1";
    swapSize = "16G";
    gcRetention = "30d";
    impermanent = true;
    gui = true;
  };
  serviceOpts = {
    dockerDir = "/mnt/docker/appdata";
    proxyDir = "/run/selfhosting/proxy-confs";
  };

  # Backup config
  backupOpts = {
    localRepo = "ssh://borg@borg:2222/backup";
    remoteRepo = "/mnt/B2/borg";
    paths = [
      "${persistVol}/etc"
    ];
    patterns = [
      # Run `borg help patterns` for guidance on exclusion patterns
      "- */home/*/.git/**" #can be restored from repo
      "- **/.local/share/libvirt" #root and user vm images
      "- */var/**"
    ];
  };

  # Create impermanent directories
  environment.persistence.${persistVol} = lib.mkIf impermanent {
    directories = [
      "/var/lib/private"
    ];
  };

  # disable emergency mode from preventing system boot if there are mounting issues
  systemd.enableEmergencyMode = false;

  # remote desktop
  # gnome rdp
  #  services.gnome.gnome-remote-desktop.enable = true; # 'true' does not make the unit start automatically at boot
  #  systemd.services.gnome-remote-desktop = {
  #    wantedBy = ["graphical.target"]; # for starting the unit automatically at boot
  #  };
  #  services.displayManager.autoLogin.enable = false;
  #  services.getty.autologinUser = null;
  #  networking.firewall.allowedTCPPorts = [3389];

  #rustdesk
  #services.rustdesk-server = {
  #  enable = true;
  #  openFirewall = true;
  #};

  ##xrdp
  #services.xrdp.enable = true;

  ## Use the GNOME Wayland session
  #services.xrdp.defaultWindowManager = "${pkgs.gnome-session}/bin/gnome-session";

  ## XRDP needs the GNOME remote desktop backend to function
  #services.gnome.gnome-remote-desktop.enable = true;

  ## Open the default RDP port (3389)
  #services.xrdp.openFirewall = true;

  ## Disable autologin to avoid session conflicts
  #services.displayManager.autoLogin.enable = false;
  #services.getty.autologinUser = null;
  #  services.xrdp = {
  #    enable = true;
  #    defaultWindowManager = "${pkgs.gnome-session}/bin/gnome-session";
  #    openFirewall = true;
  #    sslKey = "/mnt/docker/appdata/swag/config/etc/letsencrypt/live/dfrp.xyz/privkey.pem";
  #    sslCert = "/mnt/docker/appdata/swag/config/etc/letsencrypt/live/dfrp.xyz/cert.pem";
  #  };

  # Networking
  networking.hostId = "7e3de5fa"; # needed for zfs
  networking.hostName = "nas";
  networking.networkmanager.enable = true;

  # Boot
  boot.loader.grub = {
    device = "nodev";
    efiSupport = true;
    efiInstallAsRemovable = true;
    useOSProber = true; # for dual boot
  };

  # use local time so dual boot doesn't mess up HW clock
  time.hardwareClockInLocalTime = true;

  # allow root ssh login for rebuilds
  users.users.root = {
    openssh.authorizedKeys.keys = lib.lists.forEach pubKeys (key: builtins.readFile key);
  };

  system.stateVersion = "25.05";
}
