{
  inputs,
  self,
  ...
}: {
  flake.nixosConfigurations.install = inputs.nixpkgs.lib.nixosSystem {
    modules = [self.nixosModules.system-install];
  };
  flake.nixosModules.system-install = {pkgs, ...}: let
    # hard-coded restore helpers for fw13 host
    root-restore = pkgs.writeShellScriptBin "root-restore" ''
      if [ "$EUID" -ne 0 ]; then
        echo "This script requires root privileges. Elevating..."
        exec sudo "$0" "$@"
      fi
      rm -rf /tmp/borg
      mkdir /tmp/borg
      borg --rsh="ssh -i ~/id_ed25519_sk_rk" \
      mount ${self.nixosConfigurations.fw13.config.services.borgbackup.jobs."local".repo} \
      /tmp/borg/fw13-root
    '';
    user-restore = pkgs.writeShellScriptBin "user-restore" ''
      rm -rf /tmp/borg
      mkdir /tmp/borg
      borg --rsh="ssh -i ~/id_ed25519_sk_rk" \
      mount ssh://borg@borg:2222/backup/fw13-ryan \
      /tmp/borg/fw13-ryan
      echo "repository fw13-ryan mounted at /tmp/borg/fw13-ryan"
    '';
  in {
    ## This file contains host-specific NixOS configuration for my minimal install host
    ## Will be rebuilt after install using a permanent host

    imports = [
      # import custom options
      self.modules.generic.customOptions

      # disk config
      self.diskoConfigurations.luks-lvm-imp
    ];

    # Enable flakes
    nix = {
      extraOptions = ''
        experimental-features = nix-command flakes pipe-operators
      '';
    };

    # Variable overrides
    systemOpts = {
      diskDevice = "/dev/vda";
      swapEnable = true;
      swapSize = "16G";
      impermanent = true;
    };

    # Boot config with luks
    boot = {
      loader = {
        systemd-boot = {
          enable = true;
        };
        efi.canTouchEfiVariables = true;
      };
    };

    # Networking
    networking.hostName = "testvm";
    networking.networkmanager = {
      enable = true;
    };

    # Timezone
    time.timeZone = "America/Indiana/Indianapolis";

    # System packages
    environment.systemPackages = [
      pkgs.firefox
      pkgs.git
      pkgs.vim
      pkgs.borgbackup
      pkgs.tree
      pkgs.sops
      pkgs.ssh-to-age
      root-restore
      user-restore
    ];

    # Create ssh host keys to import into sops if they don't already exist in backup
    services.openssh = {
      enable = true;
      ports = [22];
      settings.PasswordAuthentication = true;
      hostKeys = [
        {
          comment = "server key";
          path = "/etc/ssh/ssh_host_ed25519_key";
          rounds = 100;
          type = "ed25519";
        }
      ];
    };

    # minimal root and primary user configs
    users.users.root = {
      password = "changeme";
    };
    users.users.ryan = {
      password = "changeme";
      isNormalUser = true;
      extraGroups = ["wheel"];
    };
  };
}
