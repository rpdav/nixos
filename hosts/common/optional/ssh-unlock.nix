{
  lib,
  userOpts,
  ...
}: let
  # Generates a list of the keys in primary user's directory in this repo
  pubKeys = lib.filesystem.listFilesRecursive ../users/${userOpts.username}/keys;
in {
  boot.kernelParams = ["ip=dhcp"];
  boot.initrd = {
    availableKernelModules = ["r8169"];
    systemd.users.root.shell = "/bin/cryptsetup-askpass";
    network = {
      enable = true;
      ssh = {
        enable = true;
        port = 2220;
        authorizedKeys = lib.lists.forEach pubKeys (key: builtins.readFile key);
        hostKeys = [/boot/initrd/ssh_host_ed25519_key];
      };
    };
  };
}
