{
  inputs,
  pkgs,
  ...
}: {
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages =
    (with pkgs; [
      alejandra
      borgbackup
      btop
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
    ])
    ++ [
      inputs.nsearch.packages.${pkgs.system}.default
    ];
}
