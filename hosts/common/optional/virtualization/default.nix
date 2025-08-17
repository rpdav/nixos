{
  config,
  pkgs,
  lib,
  ...
}: {
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
}
