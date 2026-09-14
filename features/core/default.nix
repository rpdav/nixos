{
  inputs,
  self,
  ...
}: {
  flake.nixosModules.core = {
    pkgs,
    config,
    ...
  }: {
    ## This file contains NixOS configuration common to all hosts

    imports = [
      self.modules.generic.failureNotify
      self.modules.generic.customOptions
      self.nixosModules.homeManager
      inputs.disko.nixosModules.disko
      self.nixosModules.nix
    ];

    environment.variables = {
      EDITOR = "nvim";
    };

    system.stateVersion = "24.05";

    # config-wide hosts file
    networking.hosts = {
      # hosts
      "10.10.1.17" = ["nas" "borg"];
      "10.10.1.10" = ["retropi"];
      "${inputs.nix-secrets.vps.ip}" = ["vps"];

      # networking infrastructure
      "10.10.1.1" = ["opnsense"];
      "10.10.1.188" = ["switch"];
      "10.10.1.169" = ["office-ap"];
      "10.10.1.136" = ["ap1"];
      "10.10.1.135" = ["ap2"];
    };

    # Base fonts
    fonts = {
      packages = with pkgs; [
        noto-fonts
      ];
      fontconfig.enable = true;
    };

    # Allow local users to inhibit sleep (used for some systemd user units)
    security.polkit = {
      enable = true;
      extraConfig = ''
        polkit.addRule(function(action, subject) {
            if (action.id == "org.freedesktop.login1.inhibit-block-shutdown" &&
            subject.isInGroup("users"))
                return polkit.Result.YES;
        });
      '';
    };

    # Enable systemd failure notifications
    services.failureNotify = {
      enable = true;
      mailFrom = "${config.networking.hostName}@${inputs.nix-secrets.selfhosting.domain}";
      mailTo = inputs.nix-secrets.${config.systemOpts.primaryUser}.email.personal-mail.address;
    };

    # allow local users to mount
    programs.fuse = {
      enable = true;
      userAllowOther = true;
    };

    # CLI config
    programs.bash.completion.enable = true;
    environment.enableAllTerminfo = true;

    # Time
    time.timeZone = "America/Indiana/Indianapolis";
  };
  flake.homeModules.core = {
    config,
    osConfig,
    lib,
    pkgs,
    ...
  }: let
    pkgs-stable = inputs.nixpkgs-stable.legacyPackages.${pkgs.stdenv.hostPlatform.system};
  in {
    imports = [
      self.modules.generic.customOptions
      self.modules.generic.failureNotify
    ];

    home.stateVersion = "24.05"; # HM version I built this config around
    home.homeDirectory = osConfig.users.users.${config.home.username}.home; # This is already defined in system config

    # Let Home Manager install and manage itself.
    programs.home-manager.enable = true;

    # Allow unfree packages
    nixpkgs.config.allowUnfree = true;

    # In system, this is in a separate packages.nix - consider matching?
    home.packages = (
      with pkgs;
        (
          [
            tree
            gdu
            fastfetch
            just
          ]
          ++ lib.lists.optionals osConfig.systemOpts.gui [
            # extra browsers
            brave
            tor-browser

            # extra terminals
            alacritty

            # media
            vlc
            bibletime

            # photos
            gimp
            pinta

            # text editors and office
            typora
            kdePackages.ghostwriter
            onlyoffice-desktopeditors
            libreoffice-stable

            # utilities
            gnome-calendar
          ]
        )
        ++ lib.lists.optionals osConfig.systemOpts.gui (
          with pkgs-stable; [
            jellyfin-media-player # qtwebengine-5.15.19 flagged insecure in unstable
            #bitwarden-desktop # electron 39.8.10 marked insecure even on stable
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
      ];
    };

    # Enable systemd failure notifications
    services.failureNotify = {
      enable = true;
      mailFrom = "${osConfig.networking.hostName}@${inputs.nix-secrets.selfhosting.domain}";
      mailTo = inputs.nix-secrets.${osConfig.systemOpts.primaryUser}.email.personal-mail.address;
    };

    # misc programs
    programs = {
      bat.enable = true;
      autojump.enable = true;
      btop.enable = true;
      ripgrep.enable = true;
      yazi = {
        enable = true;
        shellWrapperName = "y";
      };
    };
    services.remmina.enable = lib.mkIf osConfig.systemOpts.gui true;

    # Theming and fonts
    # Most theming is in system config through stylix.
    fonts.fontconfig.enable = true;
    gtk.iconTheme = {
      name = osConfig.stylix.fonts.emoji.name;
      package = osConfig.stylix.fonts.emoji.package;
    };

    # session variables
    home.sessionVariables = {
      EDITOR = "nvim";
    };
  };
}
