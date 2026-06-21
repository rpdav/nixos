{...}: {
  flake.nixosModules.nasSystem = {pkgs, ...}: {
    # NAS uses GPU passthrough and its CPU does not have integrated graphics.
    # This means that if anything goes wrong after stage 1 boot,
    # there is no display output to troubleshoot. Displaylink acts as an
    # external GPU for this purpose.

    environment.systemPackages = [pkgs.displaylink];
    services.xserver.videoDrivers = [
      "displaylink"
      "modesetting"
    ];
    services.xserver = {
      enable = true;
      # Manually define the device and point it to your DisplayLink card
      # Replace 'card1' with whatever your DL card is in /dev/dri/
      #config = ''
      #  Section "Device"
      #    Identifier "DisplayLink"
      #    Driver "modesetting"
      #    Option "kmsdev" "/dev/dri/card0"
      #    Option "PageFlip" "false"
      #  EndSection
      #'';
      #windowManager.i3 = {
      #  enable = true;
      #  extraSessionCommands = ''
      #    # Automatically start a terminal in fullscreen on login
      #    ${pkgs.alacritty}/bin/alacritty --command tmux &
      #  '';
      #};

      # Displaylink does not seem to work with a simple tty.
      # A simple displayManager and windowManager are needed.
      displayManager.session = [
        {
          manage = "desktop";
          name = "Kitty";
          start = "${pkgs.kitty}/bin/kitty & wait $!";
        }
        {
          manage = "desktop";
          name = "Term";
          start = "${pkgs.xterm}/bin/xterm -ls & wait $!";
        }
      ];
    };
    services.displayManager.gdm = {
      enable = true;
    };
    programs.hyprland.enable = true;

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
  };
}
