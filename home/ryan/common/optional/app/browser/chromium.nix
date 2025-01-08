{
  pkgs,
  userOpts,
  systemOpts,
  lib,
  ...
}: {
  # Create persistent directories
  home.persistence."${systemOpts.persistVol}/home/${userOpts.username}" = lib.mkIf systemOpts.impermanent {
    directories = [
      ".config/chromium"
    ];
  };
  home.packages = with pkgs; [
    chromium
  ];

  programs.chromium = {
    enable = true;
    extensions = [
      {id = "cjpalhdlnbpafiamejdnhcphjbkeiagm";} #ublock origin
      {id = "nngceckbapebfimnlniiiahkandclblb";} #bitwarden
    ];
  };
}
