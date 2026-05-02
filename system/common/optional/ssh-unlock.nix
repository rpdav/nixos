{
  lib,
  config,
  ...
}: let
  # Generates a list of the keys in primary user's directory in this repo
  pubKeys = lib.filesystem.listFilesRecursive ../users/ryan/keys;
  bootHost = "${config.networking.hostName}-boot";
in {
  boot.kernelParams = [
    "ip=::::${bootHost}::dhcp"
  ];
  boot.initrd = {
    availableKernelModules = ["r8169"];
    network = {
      enable = true;
      ssh = {
        enable = true;
        authorizedKeys = lib.lists.forEach pubKeys (key: builtins.readFile key);
        hostKeys = [/boot/initrd/ssh_host_ed25519_key]; # must manually generate this before building
      };
    };
  };
}
