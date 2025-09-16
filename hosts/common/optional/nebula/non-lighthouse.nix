{secrets, ...}: {
  imports = [./common.nix];
  services.nebula.networks."mesh" = {
    lighthouses = ["10.112.1.1"];
    staticHostMap = {
      "10.112.1.1" = ["${secrets.vps.ip}:4242"];
    };
    relays = ["10.112.1.1"];
  };
}
