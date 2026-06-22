{
  inputs,
  self,
  ...
}: {
  flake.nixosConfigurations.install = inputs.nixpkgs.lib.nixosSystem {
    modules = [self.nixosModules.system-install];
  };
  flake.nixosModules.system-install = {pkgs, ...}: {
    ## This file contains host-specific NixOS configuration for my minimal install host
    ## Will be rebuilt after install using a permanent host

    imports = [
      # import custom options
      self.nixosModules.opts

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
    environment.systemPackages = with pkgs; [
      firefox
      git
      vim
      borgbackup
      tree
      sops
      ssh-to-age
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
