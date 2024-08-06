{ modulesPath, config, pkgs, systemSettings, userSettings, secrets, ... }:

{
  
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    ./disk-config.nix
  ];

  system.stateVersion = "24.05";

## Enable flakes
  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  boot.loader.grub = {
    # no need to set devices, disko will add all devices that have a EF02 partition to the list already
    # devices = [ ];
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  services.openssh.enable = true;

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGSJJDvRzZbvzKyA6JiI0vYfQcMaNgu699BNGJ6CE7D/ ryan@nixbook"
  ];

## Networking
  networking.hostName = "nixos-vm";

## Time
  time.timeZone = "systemSettings.timezone";

## User definitions
  users.users.${userSettings.username} = {
    hashedPassword = "${secrets.${userSettings.username}.passwordhash}";
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGSJJDvRzZbvzKyA6JiI0vYfQcMaNgu699BNGJ6CE7D/ ryan@nixbook"
    ];
  };

## Packages
  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
    curl
    vim
    wget
    htop
    git
    git-crypt
    wireguard-tools
    borgbackup
    rclone
    qdirstat
  ];
  
}
