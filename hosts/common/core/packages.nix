{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    vim
    wget
    htop
    git
    git-crypt
    rclone
    sops
    killall
  ];
}
