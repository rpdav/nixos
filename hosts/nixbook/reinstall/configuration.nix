{
  config,
  pkgs,
  ...
}: {
  # Enable flakes
  nix = {
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  # Enable support for encrypted partition
  # Remove any other auto-generated boot.loader lines
  boot = {
    loader = {
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/efi";
      };
      grub = {
        enable = true;
        device = "nodev";
        efiSupport = true;
      };
    };
    initrd.luks.devices = {
      crypt = {
        # UUID of the encrypted partition
        device = "/dev/disk/by-uuid/xxxxx";
        preLVM = true;
      };
    };
  };

  # Timezone
  time.timeZone = "America/Indiana/Indianapolis";

  # Useful packages for intial reinstall
  environment.systemPackages = with pkgs; [
    firefox
    git
    vim
    borgbackup
    tree
    sops
    ssh-to-age
  ];

  # Define primary user
  users.users.yourname = {
    # the hash below is for the password `changeme` - obviously only use this for this bare-bones installl config
    hashedPassword = "$6$7y9RbBEMGo1Fx.Pr$rM1PReeNvbKM1QCQvrNJ5BAYY3SlYDr49MTT0j6wv7cz5p0ezPz8ddihkyutowzEie1.NGFxzSpfawY0s9L2q1";
    isNormalUser = true;
    extraGroups = ["wheel"]; # Enable ‘sudo’ for the user.
  };

  # Enable gnome on xserver
  services.xserver = {
    enable = true;
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
  };

  system.stateVersion = "24.05"; # Change this to the version of your installer
}
