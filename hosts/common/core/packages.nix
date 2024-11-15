{ config, pkgs, ... }:
{
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    vim
    wget
    htop
    git
    git-crypt
    rclone
    sops
    killall
    pciutils
    usbutils
  ];
}
