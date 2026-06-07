{
  pkgs,
  lib,
  config,
  osConfig,
  secrets,
  ...
}: {
  imports = [
    ./git.nix
    ./ssh.nix
  ];
  programs.lazydocker = {
    enable = true;
    settings = {
      gui.returnImmediately = true;
    };
  };
  home.packages = [
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
  ];

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

  home.persistence."${config.systemOpts.persistVol}" = lib.mkIf config.userOpts.impermanent {
    directories = [
      ".config/remmina"
    ];
  };
}
