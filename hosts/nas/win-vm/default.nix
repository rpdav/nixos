{inputs, ...}: let
  inherit (inputs) nixvirt;
in {
  imports = [inputs.nixvirt.nixosModules.default];

  boot.initrd.kernelModules = [
    "vfio_pci"
    "vfio"
    "vfio_iommu_type1"
  ];
  boot.kernelParams = [
    "amd_iommu=on"
    #"vfio-pci.ids=10de:2182,10de:1aeb,10de:1aec,10de:1aed" # bind gpu to vfio
  ];

  virtualisation.libvirt = {
    enable = true;
    connections."qemu:///system" = {
      networks = [
        #{
        #  definition = nixvirt.lib.network.writeXML (nixvirt.lib.network.templates.bridge
        #    {
        #      name = "default";
        #      uuid = "5046a610-afae-4b85-9f00-8beb9c101f95";
        #      subnet_byte = 54;
        #    });
        #  active = true;
        #  restart = true;
        #}
        {
          definition = builtins.toFile "network.xml" (nixvirt.lib.network.getXML {
            name = "default";
            forward.mode = "bridge";
            bridge.name = "br0";
          });
        }
      ];
      domains = [
        {
          definition = ./win10.xml;
          active = true;
        }
      ];
    };
  };
}
