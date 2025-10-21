{inputs, ...}: {
  imports = [inputs.NixVirt.nixosModules.default];
  virtualisation.libvirt = {
    enable = true;
    connections."qemu:///system" = {
      networks = [
        {
          definition = ./network.xml;
          active = true;
        }
      ];
      domains = [
        {
          definition = ./ubuntu.xml;
          active = true;
        }
      ];
    };
  };
}
