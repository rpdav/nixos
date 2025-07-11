{
  config,
  pkgs,
  ...
}: {
  virtualisation.libvirtd = {
    enable = true;
    qemu.vhostUserPackages = with pkgs; [virtiofsd];
  };
  programs.virt-manager.enable = true;
  users.users.${config.userOpts.username}.extraGroups = ["libvirtd"];
  virtualisation.spiceUSBRedirection.enable = true;

  environment.systemPackages = with pkgs; [
    dnsmasq
  ];
}
