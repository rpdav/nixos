{lib, ...}: let
  # Generates a list of the keys in primary user's directory in this repo
  pubKeys = lib.filesystem.listFilesRecursive ../common/users/ryan/keys;
in {
  boot.kernelParams = ["ip=10.10.1.17::10.10.1.1:255.255.255.0::enp34s0:none"];
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
