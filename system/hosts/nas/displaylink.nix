{pkgs, ...}: {
  environment.systemPackages = [pkgs.displaylink];
  services.xserver.videoDrivers = [
    "displaylink"
    "modesetting"
  ];
  services.xserver = {
    enable = true;
    # Use 'startx' to prevent a graphical login manager (GDM/SDDM) from starting
    #displayManager.startx.enable = true;
    displayManager.session = [
      {
        manage = "desktop";
        name = "Kitty";
        start = ''
          ${pkgs.kitty}/bin/kitty & wait $!
        '';
      }
    ];

    services.displayManager.gdm = {
      enable = true;
    };

    # Manually define the device and point it to your DisplayLink card
    # Replace 'card1' with whatever your DL card is in /dev/dri/
    config = ''
      Section "Device"
        Identifier "DisplayLink"
        Driver "modesetting"
        Option "kmsdev" "/dev/dri/card0"
        Option "PageFlip" "false"
      EndSection
    '';
  };
  boot.extraModprobeConfig = "options evdi initial_device_count=1";
  boot.kernelModules = [
    "evdi"
    "fbcon"
  ];
  boot.blacklistedKernelModules = [
    "udl"
  ];
  boot.kernelParams = [
    #"udl.fbdev=1" # Forces the udl driver to create a framebuffer
    "fbcon=map:0" # Maps the console to the newly created fb
    "fbcon=primary:0"
    "video=DVI-I-1:1920x1080@60"
    "video=DVI-I-1:e"
  ];
}
