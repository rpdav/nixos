{pkgs, ...}: {
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
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
    vim
  ];
}
