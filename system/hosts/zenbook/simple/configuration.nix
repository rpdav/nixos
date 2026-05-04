{
  lib,
  pkgs,
  config,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ./disko.nix
  ];

  # https://wiki.nixos.org/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "26.05";

  # Boot config
  boot = {
    loader = {
      systemd-boot = {
        enable = false;
      };
      efi.canTouchEfiVariables = true;
    };
  };

  # Networking
  networking.hostName = "zenbook";
  networking.networkmanager = {
    enable = true;
  };

  # System packages
  environment.systemPackages = with pkgs; [
    blueman
    qdirstat
    git
    vim
    alejandra
    bat
    dust
    eza
    htop
    killall
    nix-output-monitor
    nix-tree
    pciutils
    systemctl-tui
    usbutils
    wget
    yazi
  ];

  # Enable SSH
  services.openssh = {
    enable = true;
    ports = [22];
    settings.PasswordAuthentication = false;
    hostKeys = [
      {
        comment = "server key";
        path = "/etc/ssh/ssh_host_ed25519_key";
        rounds = 100;
        type = "ed25519";
      }
    ];
  };

  # root user config
  users.users.root = {
    password = "changeme";
    openssh.authorizedKeys.keys = [
      "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIKPkpw5aW6ChMqsuaXlElY/Y4UyNgicjBfo0X3S1r9lxAAAABHNzaDo= ryan@yubi5c"
    ];
  };

  # main user config
  users.users.ryan = {
    isNormalUser = true;
    group = "ryan";
    password = "changeme";
    openssh.authorizedKeys.keys = [
      "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIKPkpw5aW6ChMqsuaXlElY/Y4UyNgicjBfo0X3S1r9lxAAAABHNzaDo= ryan@yubi5c"
    ];
  };
  users.groups.ryan = {};
}
