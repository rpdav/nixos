{inputs, ...}: {
  flake.nixosModules.virtualization = {
    config,
    pkgs,
    lib,
    ...
  }: {
    imports = [inputs.nixvirt.nixosModules.default];

    # Create persistent directories
    environment.persistence."${config.systemOpts.persistVol}" = lib.mkIf config.systemOpts.impermanent {
      directories = [
        "/var/lib/libvirt"
        "/etc/libvirt"
      ];
    };
    virtualisation.libvirtd = {
      enable = true;
      qemu.vhostUserPackages = with pkgs; [virtiofsd];
    };

    networking.firewall.trustedInterfaces = ["virbr0"];

    programs.virt-manager.enable = true;
    users.users.ryan.extraGroups = ["libvirtd"];
    virtualisation.spiceUSBRedirection.enable = true;

    environment.systemPackages = with pkgs; [
      dnsmasq
    ];

    # Enable default network and auto-start with nixvirt
    virtualisation.libvirt = {
      enable = lib.mkDefault true;
      connections."qemu:///system" = {
        networks = [
          {
            definition = inputs.nixvirt.lib.network.writeXML {
              name = "default";
              uuid = "5046a610-afae-4b85-9f00-8beb9c101f95";
              forward = {
                mode = "nat";
                port = {
                  start = 1024;
                  end = 65535;
                };
              };
              bridge.name = "virbr0";
              ip = let
                prefix = "192.168.54.";
              in {
                address = "${prefix}1";
                netmask = "255.255.255.0";
                dhcp = {
                  range = {
                    start = "${prefix}2";
                    end = "${prefix}254";
                  };
                };
              };
            };
            active = true;
          }
        ];
      };
    };

    # virt-manager HM settings
    home-manager.users.ryan.dconf.settings = {
      "org/virt-manager/virt-manager" = {
        xmleditor-enabled = true;
      };
      "org/virt-manager/virt-manager/connections" = {
        uris = [
          "qemu+ssh://root@10.10.1.17/system"
          "qemu:///system"
        ];
        autoconnect = [
          "qemu+ssh://root@10.10.1.17/system"
          "qemu:///system"
        ];
      };
    };
  };
}
