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
    restore = pkgs.writeShellScriptBin "-restore" ''
      if [ "$EUID" -ne 0 ]; then
        echo "This script requires root privileges. Elevating..."
        exec sudo "$0" "$@"
      fi
      mkdir -p /tmp/borg/{fw13-root,fw13-ryan}
      # mount root repo
      echo "*** mounting root backup ***"
      echo "*** touch yubikey after entering pin ***"
      borg mount ssh://borg@borg:2222/backup/fw13-root \
      /tmp/borg/fw13-root
      # mount user repo
      echo "*** mounting user backup ***"
      echo "*** touch yubikey after entering pin ***"
      borg mount ssh://borg@borg:2222/backup/fw13-ryan \
      /tmp/borg/fw13-ryan
    '';
  in {
    ## This file contains host-specific NixOS configuration for my minimal install host
    ## Will be rebuilt after install using a permanent host config

    imports = [
      # import custom options
      self.modules.generic.customOptions

      # disk config
      self.diskoConfigurations.luks-lvm-imp
    ];

    # Enable flakes and other features
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
    networking.hostName = "fw13";
    networking.networkmanager = {
      enable = true;
    };

    # Timezone
    time.timeZone = "America/Indiana/Indianapolis";

    # Tools for reinstall
    environment.systemPackages = [
      pkgs.git
      pkgs.vim
      pkgs.borgbackup
      pkgs.tree
      pkgs.sops
      pkgs.ssh-to-age
      restore
    ];

    # Define ssh keys for secrets repo and backup access
    # Not a real private key; only a stub file for a resident key
    systemd.tmpfiles.rules = [
      "d /home/install/.ssh 0700 install install -"
      "C /home/install/.ssh/id_ed25519_sk_rk 0600 install users - ${./id_ed25519_sk_rk}"
      "C /home/install/.ssh/id_ed25519_sk_rk.pub 0644 install users - ${./id_ed25519_sk_rk.pub}"
    ];

    # ssh config for github and borg
    programs.ssh.extraConfig = ''
      Host github.com
        IdentityFile /home/install/.ssh/id_ed25519_sk_rk
        IdentitiesOnly yes
      Host borg
        HostName ${self.deploy.nodes.nas.hostname}
        IdentityFile /home/install/.ssh/id_ed25519_sk_rk
        IdentitiesOnly yes
    '';
    programs.ssh.knownHosts."github.com".publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";

    # minimal root and primary user configs
    users.users.root = {
      password = "changeme";
    };
    users.users.install = {
      password = "changeme";
      isNormalUser = true;
      extraGroups = ["wheel"];
    };
  };
}
