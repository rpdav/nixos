{
  config,
  lib,
  ...
}:
# This file contains short-term fixes for upstream bugs that haven't been patched.
# Best practice is to use mkIf to make sure the overrides only apply to systems that need it.
# Check this periodically after updating lock file to see if patches are still needed.
{
  # Bug in libvirtd causes libvirtd.service to fail.
  # Deleting /var/lib/libvirt/secrets contents seems to fix it
  # Has to be re-deleted on each reboot, so using tmpfiles
  # https://github.com/NixOS/nixpkgs/issues/501336
  # Still open as of 02-May-26
  systemd.tmpfiles.rules = lib.mkIf config.virtualisation.libvirtd.enable [
    "r /var/lib/libvirt/secrets/secrets-encryption-key"
  ];

  # LDAP test failure (dep of lutris) causing build failures.
  # Skipping tests while upstream sorts it out, revert once
  # Hydra consistently builds openldap green.
  # https://github.com/NixOS/nixpkgs/issues/513245
  nixpkgs.overlays = lib.mkIf config.programs.steam.enable [
    (final: prev: {
      openldap = prev.openldap.overrideAttrs (_: {
        doCheck = false;
      });
    })
  ];
}
