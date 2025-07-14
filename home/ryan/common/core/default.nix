{
  config,
  osConfig,
  lib,
  secrets,
  pkgs,
  userOpts,
  ...
}: {
  imports = [
    ./bash.nix
    ./git.nix
    ./sops.nix
    ./ssh.nix
    ./starship.nix
  ];

  home.packages = with pkgs; (
    [
      tree
      gdu
      fastfetch
      just

      # scripts
      (import ../optional/scripts/fs-diff.nix {inherit pkgs;})
      (import ../optional/scripts/clear-testbox.nix {
        inherit pkgs;
        inherit config;
      })
      (import ../optional/scripts/clear-testvm.nix {
        inherit pkgs;
        inherit config;
      })
      (import ../optional/scripts/clear-vps.nix {
        inherit pkgs;
        inherit config;
      })
      (import ../optional/scripts/lish.nix {
        inherit pkgs;
        inherit secrets;
      })
    ]
    ++ lib.lists.optionals osConfig.systemOpts.gui [
      # browsers
      brave
      tor-browser
      librewolf

      # terminals
      alacritty

      # media
      audacity
      vlc
      bibletime
      jellyfin-media-player

      # photos
      gimp
      pinta

      # text editors and office
      typora
      kdePackages.ghostwriter
      onlyoffice-bin

      # utilities
      remmina
      bitwarden-desktop
      gnome-calendar
    ]
  );

  # Create persistent directories
  home.persistence."${config.systemOpts.persistVol}${config.home.homeDirectory}" = lib.mkIf config.systemOpts.impermanent {
    directories = [
      ".config/BraveSoftware"
      ".config/GIMP"
      ".config/Nextcloud"
      ".config/onlyoffice"
      ".config/remmina"
    ];
    files = [
      ".config/ghostwriterrc"
      ".config/bluedevelglobalrc" # bluetooth
    ];
  };
  programs.bat.enable = true;

  programs.autojump.enable = true;

  programs.btop.enable = true;

  programs.ripgrep.enable = true;

  home.sessionVariables = {
    EDITOR = osConfig.userOpts.editor;
  };
}
