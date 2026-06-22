{...}: {
  flake.nixosModules.sshUnlock = {config, ...}: {
    boot.initrd = {
      availableKernelModules = ["r8169"];
      network = {
        enable = true;
        ssh = {
          enable = true;
          port = 2222;
          authorizedKeyFiles = config.users.users.ryan.openssh.authorizedKeys.keyFiles;
          hostKeys = [/boot/initrd/ssh_host_ed25519_key]; # must manually generate this before building
        };
      };
    };
  };
}
