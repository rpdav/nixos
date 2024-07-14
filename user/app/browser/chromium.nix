{ config, pkgs, ... }:

{

  home.packages = with pkgs; [
    chromium
  ];

  programs.chromium = {
    enable = true;
    extensions = [
      { id = "cjpalhdlnbpafiamejdnhcphjbkeiagm"; } #ublock origin
      { id = "nngceckbapebfimnlniiiahkandclblb"; } #bitwarden
    ];
  };

}
