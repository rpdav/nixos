{
  # This file contains short-term fixes for upstream bugs that haven't been patched.
  # Best practice is to use mkIf to make sure the overrides only apply to systems that need it.
  # Check this periodically after updating lock file to see if patches are still needed.
  flake.nixosModules.core = {
    config,
    lib,
    pkgs-stable,
    ...
  }: let
  in {
    nixpkgs.config.problems.handlers = {
      "gtk+".broken = "warn"; # downgrade gtk2 error to warning; too many packages not fixed yet
    };

    # Bug in libvirtd causes libvirtd.service to fail.
    # Deleting /var/lib/libvirt/secrets contents seems to fix it
    # Has to be re-deleted on each reboot, so using tmpfiles
    # https://github.com/NixOS/nixpkgs/issues/501336
    # Still open as of 02-May-26
    systemd.tmpfiles.rules = lib.mkIf config.virtualisation.libvirtd.enable [
      "r /var/lib/libvirt/secrets/secrets-encryption-key"
    ];

    # 31-Aug-26: after flake update, esphome.service fails to start.
    # It says dashboard has been removed from the esphome binary and
    # has been replaced by esphome-device-builder. EDB is in nixpkgs
    # but is not in the service config. No github issue yet.
    # from serviceModules.home-assistant
    services.esphome.package = pkgs-stable.esphome;
  };
  flake.homeModules.core = {pkgs-stable, ...}: {
    # 23-Nov-26: wayprompt package removed from upstream but not yet removed from stylix.
    # https://github.com/nix-community/stylix/issues/2556
    stylix.targets.wayprompt.enable = false;

    # 25-Nov-26: unstable joplin-desktop can't copy/paste
    # No issues found on source or nixpkgs githubs
    programs.joplin-desktop.package = pkgs-stable.joplin-desktop;
  };
}
