{...}: {
  imports = [./common.nix];
  services.nebula.networks."mesh" = {
    # lighthouse config
    isLighthouse = true;
    isRelay = true;
  };
}
