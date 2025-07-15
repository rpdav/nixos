{
  config,
  osConfig,
  lib,
  ...
}: let
  inherit (osConfig) systemOpts;
in {
  # Create persistent directories
  home.persistence."${systemOpts.persistVol}${config.home.homeDirectory}" = lib.mkIf systemOpts.impermanent {
    directories = [
      ".config/chromium"
    ];
  };

  programs.chromium = {
    enable = true;
    extensions = [
      {id = "ddkjiahejlhfcafbddmgiahcphecmpfh";} #ublock origin lite
      {id = "nngceckbapebfimnlniiiahkandclblb";} #bitwarden
    ];
  };
}
