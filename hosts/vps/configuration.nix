{
  inputs,
  self,
  ...
}: {
  flake.nixosConfigurations.vps = inputs.nixpkgs.lib.nixosSystem {
    modules = [self.nixosModules.system-vps];
  };
  flake.nixosModules.system-vps = {
    lib,
    pkgs,
    config,
    ...
  }:
  ## This file contains host-specific NixOS configuration for host vps
  ## CPU: AMD MD EPYC 7713 single core (VM)
  ## GPU: None
  ## RAM: 1 GB
  let
    inherit (config.systemOpts) persistVol impermanent;
  in {
    imports = [
      # core config
      self.nixosModules.core

      # optional
      self.nixosModules.vim
      self.nixosModules.backupLocal
      self.nixosModules.backupRemote
      self.nixosModules.docker
      self.nixosModules.yubikey

      # users
      self.nixosModules.user-ryan

      # disk config
      self.diskoConfigurations.btrfs-imp

      # self-hosted services
      self.serviceModules.swag
      self.serviceModules.beszelAgent
      self.serviceModules.dms
      self.serviceModules.kuma
    ];

    # Variable overrides
    systemOpts = {
      primaryUser = "ryan"; #primary user (not necessarily only user)
      swapEnable = true;
      swapSize = "2G";
      diskDevice = "sda";
      gcRetention = "7d";
      impermanent = true;
      gui = false;
    };
    serviceOpts = {
      dockerDir = "/opt/docker";
      proxyDir = "/run/selfhosting/proxyConfs";
    };

    # Backup config
    backupOpts = {
      localRepo = "ssh://borg@borg:2222/backup";
      #remoteRepo = "/mnt/B2/borg";
      paths = [
        "${persistVol}/etc"
      ];
      patterns = [
        # Run `borg help patterns` for guidance on exclusion patterns
        "- */var/**" #not needed for restore
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
      openssh.authorizedKeys.keyFiles = config.users.users.ryan.openssh.authorizedKeys.keyFiles;
    };

    environment.systemPackages = with pkgs; [
      # Recommended utils per Linode
      inetutils
      mtr
      sysstat
    ];

    # VPS docker directory lives in persistent volume
    environment.persistence.${persistVol} = lib.mkIf impermanent {
      directories = [
        "${config.serviceOpts.dockerDir}"
      ];
    };

    # VPS monitoring
    sops.secrets."linode/longviewAPIKey".sopsFile = "${inputs.nix-secrets.outPath}/vps.yaml";
    services.longview = {
      enable = true;
      apiKeyFile = config.sops.secrets."linode/longviewAPIKey".path;
    };
  };
}
