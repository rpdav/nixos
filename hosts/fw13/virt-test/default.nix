{inputs, ...}: let
  inherit (inputs) nixvirt;
in {
  imports = [inputs.nixvirt.nixosModules.default];
  virtualisation.libvirt = {
    enable = true;
    connections."qemu:///system" = {
      networks = [
        {
          definition = nixvirt.lib.network.writeXML (nixvirt.lib.network.templates.bridge
            {
              name = "default";
              uuid = "5046a610-afae-4b85-9f00-8beb9c101f95";
              subnet_byte = 54;
            });
          active = true;
        }
      ];
      #domains = [
      #  {
      #    definition = ./ubuntu.xml;
      #    #definition = nixvirt.lib.domain.getXML {
      #    #  name = "ubuntu";
      #    #  uuid = "cc7439ed-36af-4696-a6f2-1f0c4474d87e";
      #    #  memory = {
      #    #    count = 6;
      #    #    unit = "GiB";
      #    #  };
      #    #  storage_vol = /var/lib/libvirt/images/ubuntu24.04-1.qcow2;
      #    #  on_reboot = "destroy";
      #    #};
      #    active = true;
      #  }
      #];
    };
  };
}
