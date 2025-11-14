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
          restart = true;
        }
      ];
      #domains = [
      #  {
      #    definition = ./win10.xml;
      #    active = true;
      #  }
      #];
    };
  };
}
