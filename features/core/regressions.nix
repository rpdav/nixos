{inputs, ...}: {
  flake.nixosModules.core = {
    config,
    lib,
    pkgs,
    ...
  }: {
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
    services.fwupd.package = inputs.nixpkgs-stable.legacyPackages.${pkgs.stdenv.hostPlatform.system}.fwupd;
  };
}
