{
  modulesPath,
  lib,
  pkgs,
  configLib,
  ...
}: {
  imports =
    lib.flatten
    [
      (map configLib.relativeToRoot [
        # core config
        "vars"
        "hosts/common/disks/btrfs-imp.nix"
      ])
      (modulesPath + "/installer/scan/not-detected.nix")
      ./hardware-configuration.nix
    ];

  # Variable overrides
  systemSettings.swapEnable = true;
  systemSettings.swapSize = "4G";
  # this changes from one reboot to next - check before deploying!
  systemSettings.diskDevice = "sdb";

  boot.loader.grub = {
    # no need to set devices, disko will add all devices that have a EF02 partition to the list already
    # devices = [ ];
    efiSupport = true;
    efiInstallAsRemovable = true;
  };
  services.openssh.enable = true;

  networking.hostName = "testbox";

  environment.systemPackages = map lib.lowPrio [
    pkgs.curl
    pkgs.gitMinimal
    pkgs.vim
  ];

  users.users.ryan = {
    # password below is "changeme" for testing
    hashedPassword = "$6$ZKA9wKFWI9uZDKeq$VVH8V1ppkzx9awRcAPJYamkg4YBxgVNIzNFEc8taEq0koSEoFFAoMFFVBks6hH5FnQ5fbNo0..hpDrhlr3b9M.";
    isNormalUser = true;
    extraGroups = ["wheel"];
  };

  users.users.root.openssh.authorizedKeys.keys = [
    # change this to your ssh key
    "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAILygGVzteEOsvhdTTP+guA4Fq0TeJM/R2tDYXXbHvhLFAAAABHNzaDo= ryan@yubinano"
  ];

  system.stateVersion = "25.05";
}
