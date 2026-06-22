{inputs, ...}: {
  flake.nixosModules.nasSystem = {
    lib,
    config,
    ...
  }: let
    router = "10.10.1.1";
  in {
    # Define host bridge network
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
              address = "10.10.1.17"; #TODO is there a better way to manage IP addresses in config?
              prefixLength = 24;
            }
          ];
        };
      };
      bridges."br0".interfaces = ["enp42s0"];
    };

    specialisation.no-passthrough.configuration = {
      # Specialization to disable passthrough for host GPU use and troubleshooting.
      # No config defined here, but some things are disabled below with conditionals:
      # `lib.mkIf (config.specialisation != {})`
      # Note this will disable it for ALL specialisations, not just no-passthrough.
      # Currently not using any other specialisations, so this is OK.
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
      (lib.mkIf (config.specialisation != {}) pci-ids) # disable passthrough if running a specialisation
    ];

    virtualisation.libvirt = {
      enable = true;
      connections."qemu:///system" = {
        networks = [
          # bridge network on same subnet as host
          {
            definition = inputs.nixvirt.lib.network.writeXML {
              name = "br0";
              uuid = "e59b4192-e88b-4b6a-a4c3-75c2ae20beac";
              forward.mode = "bridge";
              bridge.name = "br0";
            };
            active = true;
          }
        ];
        domains = [
          # win10 VM definition
          {
            definition = ./win10.xml;
            # do not auto-start win10 VM if running a specialisation
            active =
              if config.specialisation != {}
              then true
              else false;
          }
        ];
      };
    };
  };
}
