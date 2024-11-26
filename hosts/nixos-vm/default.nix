{
  lib,
  modulesPath,
  config,
  pkgs,
  pkgs-unstable,
  inputs,
  systemSettings,
  userSettings,
  secrets,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    ../../modules/disk-config.nix
    ../../variables.nix
    ../../modules/persistence
  ];

  system.stateVersion = "24.05";

  ## Enable flakes
  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  ## System-specific disk config
  systemSettings.swapSize = lib.mkForce "4G";
  systemSettings.diskDevice = lib.mkForce "/dev/vda";

  boot.loader.grub = {
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  ## SSH
  services.openssh.enable = true;
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGSJJDvRzZbvzKyA6JiI0vYfQcMaNgu699BNGJ6CE7D/ ryan@nixbook"
  ];

  ## Networking
  networking.hostName = "nixos-vm";

  ## Time
  time.timeZone = "systemSettings.timezone";

  ## User definition
  users.users.${userSettings.username} = {
    hashedPassword = "${secrets.${userSettings.username}.passwordhash}";
    isNormalUser = true;
    extraGroups = ["wheel"]; # Enable ‘sudo’ for the user.
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGSJJDvRzZbvzKyA6JiI0vYfQcMaNgu699BNGJ6CE7D/ ryan@nixbook"
    ];
  };

  ## Home Manager
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.ryan = import ./home.nix;
    sharedModules = with inputs; [
      impermanence.nixosModules.home-manager.impermanence
    ];
    extraSpecialArgs = {
      inherit pkgs-unstable;
      inherit secrets;
      inherit inputs;
    };
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
