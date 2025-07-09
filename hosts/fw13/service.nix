{
  config,
  configLib,
  ...
}: {
  imports = [(configLib.relativeToRoot "modules/nixos/proxy-conf")];

  virtualisation.oci-containers.proxy-conf.testservice = {
    container = "nextcloud";
    subdomain = "cloud";
    port = 8083;
    protocol = "https";
  };
}
