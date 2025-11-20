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
  ];

  virtualisation.libvirt = {
    enable = true;
    connections."qemu:///system" = {
      networks = [
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
