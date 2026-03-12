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

  environment.systemPackages = [pkgs.displaylink];
  services.xserver.videoDrivers = [
    "displaylink"
    "modesetting"
  ];
  services.xserver = {
    enable = true;
    # Use 'startx' to prevent a graphical login manager (GDM/SDDM) from starting
    displayManager.startx.enable = true;

    # Manually define the device and point it to your DisplayLink card
    # Replace 'card1' with whatever your DL card is in /dev/dri/
    config = ''
      Section "Device"
        Identifier "DisplayLink"
        Driver "modesetting"
        Option "kmsdev" "/dev/dri/card0"
        Option "PageFlip" "false"
      EndSection
    '';
  };
  boot.extraModprobeConfig = "options evdi initial_device_count=1";
  boot.kernelModules = [
    "evdi"
    "fbcon"
  ];
  boot.blacklistedKernelModules = [
    "udl"
  ];

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
    #"udl.fbdev=1" # Forces the udl driver to create a framebuffer
    "fbcon=map:0" # Maps the console to the newly created fb
    "fbcon=primary:0"
    "video=DVI-I-1:1920x1080@60"
    "video=DVI-I-1:e"
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
