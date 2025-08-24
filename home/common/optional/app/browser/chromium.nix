{
  config,
  osConfig,
  lib,
  ...
}: let
  inherit (osConfig) systemOpts;
in {
  # Create persistent directories
  home.persistence."${systemOpts.persistVol}${config.home.homeDirectory}" = lib.mkIf config.userOpts.impermanent {
    directories = [
      ".config/chromium"
    ];
  };

  programs.chromium = {
    enable = true;
    commandLineArgs = [
      "--ozone-platform-hint=auto"
    ];
    extensions = [
      {id = "ddkjiahejlhfcafbddmgiahcphecmpfh";} #ublock origin lite
      {id = "nngceckbapebfimnlniiiahkandclblb";} #bitwarden
    ];
  };
}
