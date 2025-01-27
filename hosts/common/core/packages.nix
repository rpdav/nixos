{pkgs, ...}: {
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    vim
    borgbackup
    wget
    htop
    git
    git-crypt
    alejandra
    rclone
    killall
    pciutils
    usbutils
    nixd
  ];
}
