{
  config,
  osConfig,
  lib,
  secrets,
  pkgs,
  pkgs-stable,
  ...
}: {
  imports = [
    ./backup.nix
    ./bash.nix
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
          remmina
          bitwarden-desktop
          gnome-calendar
        ]
      )
      ++ (
        with pkgs-stable; [
          jellyfin-media-player # qtwebengine-5.15.19 flagged insecure in unstable
        ]
      )
  );

  # Create persistent directories
  home.persistence."${config.systemOpts.persistVol}${config.home.homeDirectory}" = lib.mkIf config.userOpts.impermanent {
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
  programs.bat.enable = true;

  programs.autojump.enable = true;

  programs.btop.enable = true;

  programs.ripgrep.enable = true;

  home.sessionVariables = {
    EDITOR = "nvim";
  };
}
