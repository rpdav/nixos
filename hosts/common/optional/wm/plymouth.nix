{
  inputs,
  lib,
  ...
}: let
  system = "x86_64-linux";
  overlays = [inputs.mac-style-plymouth.overlays.default];
  pkgs = import inputs.nixpkgs {
    inherit system overlays;
  };
in {
  boot = {
    plymouth = {
      enable = true;
      theme = lib.mkForce "mac-style";
      themePackages = [pkgs.mac-style-plymouth];
    };
    kernelParams = [
      "quiet"
      "splash"
      "rd.systemd.show_status=auto"
      "rd.udev.log_level=3"
      "udev.log_priority=3"
      "boot.shell_on_fail"
    ];
    initrd.verbose = false;
  };
}
