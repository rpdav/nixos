{inputs, ...}: {
  flake.nixosModules.core = {
    config,
    lib,
    pkgs,
    ...
  }: let
    pkgs-stable = inputs.nixpkgs-stable.legacyPackages.${pkgs.stdenv.hostPlatform.system};
  in {
    # This file contains short-term fixes for upstream bugs that haven't been patched.
    # Best practice is to use mkIf to make sure the overrides only apply to systems that need it.
    # Check this periodically after updating lock file to see if patches are still needed.

    environment.systemPackages = [
      # librewolf # 24-Jun-26 - missing committer on unstable; just commenting out for now. from nixosModules.core
    ];

    # Bug in libvirtd causes libvirtd.service to fail.
    # Deleting /var/lib/libvirt/secrets contents seems to fix it
    # Has to be re-deleted on each reboot, so using tmpfiles
    # https://github.com/NixOS/nixpkgs/issues/501336
    # Still open as of 02-May-26
    systemd.tmpfiles.rules = lib.mkIf config.virtualisation.libvirtd.enable [
      "r /var/lib/libvirt/secrets/secrets-encryption-key"
    ];

    # 24-Jun-26: fwupd-2.1.5 fails to build on unstable
    services.fwupd.package = pkgs-stable.fwupd;

    # 31-Aug-26: after flake update, esphome.service fails to start.
    # It says dashboard has been removed from the esphome binary and
    # has been replaced by esphome-device-builder. EDB is in nixpkgs
    # but is not in the service config. No github issue yet.
    # from serviceModules.home-assistant
    services.esphome.package = pkgs-stable.esphome;
  };
}
