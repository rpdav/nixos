{inputs, ...}: let
  inherit (inputs) NixVirt;
in {
  imports = [inputs.NixVirt.nixosModules.default];
  virtualisation.libvirt = {
    enable = true;
    connections."qemu:///system" = {
      networks = [
        {
          definition = NixVirt.lib.network.writeXML (NixVirt.lib.network.templates.bridge
            {
              name = "default";
              uuid = "5046a610-afae-4b85-9f00-8beb9c101f95";
              subnet_byte = 54;
            });
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
