{
  pkgs,
  inputs,
  ...
}: {
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    vim
    wget
    htop
    git
    git-crypt
    alejandra
    rclone
    sops
    killall
    pciutils
    usbutils
    neovim
    nixd
  ];

}
