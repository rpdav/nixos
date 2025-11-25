{
  inputs,
  pkgs,
  ...
}: let
  inherit (inputs) nixvirt;
in {
  imports = [inputs.nixvirt.nixosModules.default];

  # define bridge network
  networking = {
    interfaces = {
      "enp34s0".useDHCP = false;
      "br0".useDHCP = true;
    };
    bridges."br0".interfaces = ["enp34s0"];
  };

  # kernel modules for passthrough
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
        # bridge network on same subnet as host
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
        # win10 vm definition
        {
          definition = ./win10.xml;
          active = true;
        }
      ];
    };
  };
}
