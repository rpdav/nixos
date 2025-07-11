{
  inputs,
  config,
  lib,
  pkgs,
  ...
}: {
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages =
    (
      with pkgs;
        [
          # Core packages for all systems
          alejandra
          bat
          borgbackup
          dust
          git
          git-crypt
          htop
          killall
          nix-output-monitor
          nix-tree
          pciutils
          rclone
          systemctl-tui
          usbutils
          vim
          wget
          yazi
        ]
        ++ lib.lists.optionals config.systemOpts.gui [
          # Core packages for gui systems
          btrfs-assistant
          bitwarden-desktop
        ]
    )
    ++ [
      inputs.nsearch.packages.${pkgs.system}.default
    ];
}
