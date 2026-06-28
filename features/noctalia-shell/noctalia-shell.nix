{inputs, ...}: {
  flake.homeModules.noctalia-shell = {...}: {
    imports = [inputs.noctalia.homeModules.default];
    programs.noctalia = {
      enable = true;
      #settings = {
      #};
    };
  };
}
