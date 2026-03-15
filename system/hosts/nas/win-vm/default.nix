{
  inputs,
  lib,
  pkgs,
  ...
}: let
  inherit (inputs) nixvirt;
  router = "10.10.1.1";
in {
  imports = [inputs.nixvirt.nixosModules.default];

  # define bridge network
  networking = {
    defaultGateway = router;
    nameservers = [router];
    interfaces = {
      "enp42s0".useDHCP = false;
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
    bridges."br0".interfaces = ["enp42s0"];
  };

  # kernel modules for passthrough
  boot.initrd.kernelModules = [
    "vfio_pci"
    "vfio"
    "vfio_iommu_type1"
  ];
  boot.kernelParams = let
    # Helper function to convert nix list of PCI IDs into kernel param format
    pci-ids =
      "vfio-pci.ids="
      + (lib.concatStringsSep "," [
        "8086:e20b" # GPU
        "8086:e2f7" # GPU audio
        "8086:e2ff" # PCI bridge
        "8086:e2f0" # PCI bridge
        "8086:e2f1" # PCI bridge
      ]);
  in [
    "amd_iommu=on"
    pci-ids
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
          active = false;
        }
      ];
    };
  };
}
