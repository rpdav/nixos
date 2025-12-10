{
  inputs,
  lib,
  pkgs,
  ...
}: {
  boot = {
    # enable plymouth
    plymouth = {
      enable = true;
      theme = lib.mkForce "seal"; # mkForce to override stylix
      themePackages = with pkgs; [
        # By default we would install all themes
        (adi1090x-plymouth-themes.override {
          selected_themes = ["seal"];
        })
      ];
    };
    initrd.systemd.enable = true; # needed for plymouth display during initrd crypt unlock

    # quiet boot. Works best with gdm for smooth transition.
    kernelParams = [
      "quiet"
      "splash"
      "rd.systemd.show_status=auto"
      "rd.udev.log_level=3"
      "udev.log_priority=3"
    ];
    initrd.verbose = false;
  };
}
