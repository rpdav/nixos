# Add your reusable NixOS modules to this directory, on their own file (https://wiki.nixos.org/wiki/NixOS_modules).
# These should be stuff you would like to share with others, not your personal configurations.
# This is how EmergentMind set this up, but doesn't work for some reason:
#{
#  yubikey = import ./yubikey;
#}
{
  #  imports = [
  #    ./yubikey.nix
  #    ./proxy-conf.nix
  #    ./container-mount.nix
  #  ];
  yubikey = import ./yubikey.nix;
  proxy-conf = import ./proxy-conf.nix;
  container-mount = import ./container-mount.nix;
}
