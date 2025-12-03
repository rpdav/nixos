{inputs, ...}: let
  inherit (inputs) nixvirt;
in {
  imports = [inputs.nixvirt.nixosModules.default];

  # define bridge network
  networking = {
    defaultGateway = "10.10.1.1";
    interfaces = {
      "enp34s0".useDHCP = false;
      "br0" = {
        useDHCP = true;
        macAddress = "00:DB:61:CA:AD:BE";
        ipv4.addresses = [
          {
            address = "10.10.1.17";
            prefixLength = 24;
          }
        ];
      };
    };
    bridges."br0".interfaces = ["enp34s0"];
  };
  # flush IP from initrd ssh server. Otherwise it
  # keeps the IP even though useDHCP is disabled above.
  #boot.initrd.postMountCommands = ''
  #  ip addr flush dev enp34s0 || true
  #'';

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
