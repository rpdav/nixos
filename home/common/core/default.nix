{
  config,
  osConfig,
  lib,
  configLib,
  secrets,
  pkgs,
  nixpkgs-stable,
  ...
}: let
  pkgs-stable = nixpkgs-stable.legacyPackages.${pkgs.stdenv.hostPlatform.system};
in {
  imports = [
    (configLib.relativeToRoot "vars")
    ./backup.nix
    ./bash.nix
    ./persist.nix
    ./sops.nix
    ./ssh.nix
    ./starship.nix
  ];

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  home.packages = (
    with pkgs;
      (
        [
          tree
          gdu
          fastfetch
          just

          ### scripts

          # nix file conversion tools
          (import ./scripts/json2nix.nix {inherit pkgs;})
          (import ./scripts/toml2nix.nix {inherit pkgs;})
          (import ./scripts/yaml2nix.nix {inherit pkgs;})
          (import ./scripts/nix2json.nix {inherit pkgs;})
          (import ./scripts/nix2toml.nix {inherit pkgs;})
          (import ./scripts/nix2yaml.nix {inherit pkgs;})

          # remote host management
          (import ./scripts/clear-testbox.nix {
            inherit pkgs;
            inherit config;
          })
          (import ./scripts/clear-testvm.nix {
            inherit pkgs;
            inherit config;
          })
          (import ./scripts/clear-vps.nix {
            inherit pkgs;
            inherit config;
          })
          (import ./scripts/lish.nix {
            inherit pkgs;
            inherit secrets;
          })

          (import ./scripts/nix-search-tv.nix {inherit pkgs;})

          # misc
          (import ./scripts/fs-diff.nix {inherit pkgs;})
        ]
        ++ lib.lists.optionals osConfig.systemOpts.gui [
          # browsers
          brave
          tor-browser
          librewolf

          # terminals
          alacritty

          # media
          #audacity
          vlc
          bibletime

          # photos
          gimp
          pinta

          # text editors and office
          typora
          kdePackages.ghostwriter
          onlyoffice-desktopeditors

          # utilities
          gnome-calendar
        ]
      )
      ++ lib.lists.optionals osConfig.systemOpts.gui (
        with pkgs-stable; [
          jellyfin-media-player # qtwebengine-5.15.19 flagged insecure in unstable
          bitwarden-desktop # reverting to stable due to electron insecurity in unstable
        ]
      )
  );

  # Create persistent directories
  home.persistence."${config.systemOpts.persistVol}" = lib.mkIf config.userOpts.impermanent {
    directories = [
      ".config/Bitwarden"
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

  # misc programs
  programs = {
    bat.enable = true;
    autojump.enable = true;
    btop.enable = true;
    ripgrep.enable = true;
  };
  services.remmina.enable = lib.mkIf osConfig.systemOpts.gui true;

  # session variables
  home.sessionVariables = {
    EDITOR = "nvim";
  };
}
