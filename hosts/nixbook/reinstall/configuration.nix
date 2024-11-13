## Enable flakes
  nix = {
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

## Enable support for encrypted partition
## Remove any other auto-generated boot.loader lines
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
                 ## UUID of the encrypted partition 
        device = "/dev/disk/by-uuid/xxxxx";
        preLVM = true;
      };
    };
  };

## Timezone
  time.timeZone = "America/Indiana/Indianapolis";

## Useful packages for intial reinstall
  environment.systemPackages = with pkgs; [
    firefox
    git
    vim
    borgbackup
    tree
    sops
    ssh-to-age
  ];

## Define primary user
  users.users.yourname = {
    hashedPassword = "Run mkpasswd -m sha-512 to generate";
    isNormalUser = true; 
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
  };

## Enable gnome on xserver
  services.xserver = {
    enable = true;
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
  };

## This should not be changed unless doing a fresh install
  system.stateVersion = "24.05"; # Did you read the comment?
