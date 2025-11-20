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
          definition = nixvirt.lib.network.writeXML {
            name = "default";
            uuid = "e59b4192-e88b-4b6a-a4c3-75c2ae20beac";
            forward.mode = "bridge";
            bridge.name = "br0";
          };
          active = true;
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
