{
  description = "Ryan's NixOS configs";

  ##########################################################################
  # INPUTS
  ##########################################################################
  inputs = {
    # ── Core Nixpkgs ────────────────────────────────────────
    nixpkgs.url = "nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "nixpkgs/nixos-26.05";

    # ── Home‑manager ────────────────────────────────────────
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # ── Utility flakes ──────────────────────────────────────
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      # flake-parts does not use nixpkgs as an input; no override
    };
    import-tree = {
      url = "github:vic/import-tree";
      # import-tree does not use nixpkgs as an input; no override
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.3";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvirt = {
      url = "https://flakehub.com/f/AshleyYakeley/NixVirt/*.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware = {
      url = "github:NixOS/nixos-hardware/master";
      # nixos-hardware does not use nixpkgs as an input; no override
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence = {
      url = "github:nix-community/impermanence";
    };
    uptix = {
      url = "github:luizribeiro/uptix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nvf = {
      url = "github:notashelf/nvf";
      # separate cache server - no follow nixpkgs
    };
    nixos-cli = {
      url = "github:nix-community/nixos-cli";
      # separate cache server - no follow nixpkgs
    };
    nixos-raspberrypi = {
      url = "github:nvmd/nixos-raspberrypi/main";
      inputs.nixpkgs.follows = "nixpkgs";
      # separate cache server - no follow nixpkgs
    };

    # ── GUI‑related flakes ───────────────────────────────────────
    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland = {
      url = "github:hyprwm/Hyprland";
      # separate cache server - no follow nixpkgs
    };
    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };

    # ── Personal / secret repos ─────────────────────────────────
    nix-secrets = {
      url = "git+https://git.dfrp.xyz/ryan/nix-secrets";
    };
  };

  ##########################################################################
  # OUTPUTS
  ##########################################################################
  outputs = inputs:
    inputs.flake-parts.lib.mkFlake
    {inherit inputs;} {
      imports = [
        inputs.home-manager.flakeModules.home-manager # needed to merge homeModules. Move to config later
        # Add modules here as they are brought into flake-parts
        # Once conversion is done, this will be replaced with import-tree
        # This list will get really long

        # general modules
        ./modules/nixos
        ./modules/home-manager
        ./vars
        ./parts.nix

        # disk configs
        ./system/common/disks/luks-lvm-imp.nix
        ./system/common/disks/btrfs-imp.nix

        # users
        ./system/common/users/ariel
        ./system/common/users/retro
        ./system/common/users/ryan

        # hosts
        ./system/hosts/fw13
        ./system/hosts/fw13/hardware-configuration.nix
        ./system/hosts/nas
        ./system/hosts/nas/hardware-configuration.nix
        ./system/hosts/nas/win-vm
        ./system/hosts/nas/zfs
        ./system/hosts/nas/ups.nix
        ./system/hosts/nas/displaylink.nix
        ./system/hosts/vps
        ./system/hosts/vps/hardware-configuration.nix
        ./system/hosts/install
        ./system/hosts/install/hardware-configuration.nix
        ./system/hosts/iso
        ./system/hosts/vivobook
        ./system/hosts/vivobook/hardware-configuration.nix
        ./system/hosts/testvm
        ./system/hosts/testvm/hardware-configuration.nix
        ./system/hosts/retropi
        ./system/hosts/retropi/hardware-configuration.nix

        # system modules
        ./system/common/core
        ./system/common/optional/vim.nix
        ./system/common/optional/backup
        ./system/common/optional/docker.nix
        ./system/common/optional/duplicati.nix
        ./system/common/optional/plymouth.nix
        ./system/common/optional/ssh-unlock.nix
        ./system/common/optional/steam.nix
        ./system/common/optional/vim.nix
        ./system/common/optional/wifi.nix
        ./system/common/optional/wine.nix
        ./system/common/optional/yubikey.nix
        ./system/common/optional/virtualization
        ./system/common/optional/wm/cinnamon.nix
        ./system/common/optional/wm/hyprland.nix
        ./system/common/optional/wm/retroarch.nix

        # home configs
        ./home/ariel/fw13.nix
        ./home/ariel/vivobook.nix
        ./home/retro/retropi.nix
        ./home/ryan/fw13.nix
        ./home/ryan/vivobook.nix
        ./home/ryan/retropi.nix
        ./home/ryan/nas.nix
        ./home/ryan/testvm.nix
        ./home/ryan/vps.nix

        # home core
        ./home/common/core
        ./home/common/optional/accounts.nix
        ./home/common/optional/yubikey.nix
        ./home/common/optional/app/defaultapps.nix
        ./home/common/optional/app/kitty.nix
        ./home/common/optional/app/nextcloud.nix
        ./home/common/optional/app/thunderbird.nix
        ./home/common/optional/app/browser
        ./home/common/optional/app/games
        ./home/common/optional/app/web-apps
        ./home/common/optional/wm/cinnamon.nix
        ./home/common/optional/wm/cosmic.nix
        ./home/common/optional/wm/retroarch.nix
        ./home/common/optional/wm/hyprland/default.nix
        ./home/common/optional/wm/hyprland/hypridle.nix
        ./home/common/optional/wm/hyprland/hyprlock.nix
        ./home/common/optional/wm/hyprland/waybar
        ./home/common/optional/wm/hyprland/wlogout

        # selfhosted services
        ./services/common/swag
        ./services/common/beszel-agent
        ./services/nas/actual
        ./services/nas/albyhub
        ./services/nas/beszel-hub
        ./services/nas/borg
        ./services/nas/duplicati
        ./services/nas/flatnotes
        ./services/nas/gitea
        ./services/nas/guacamole
        ./services/nas/heimdall
        ./services/nas/home-assistant
        ./services/nas/immich
        ./services/nas/jellyfin
        ./services/nas/lubelogger
        ./services/nas/nextcloud
        ./services/nas/planka
        ./services/nas/searxng
        ./services/nas/speedtest
        ./services/nas/sunshine
        ./services/nas/unifi
        ./services/nas/vaultwarden
        ./services/vps/dms
        ./services/vps/kuma
        ./services/common/swag/docker-compose.nix
        ./services/nas/actual/docker-compose.nix
        ./services/nas/albyhub/docker-compose.nix
        ./services/nas/borg/docker-compose.nix
        ./services/nas/duplicati/docker-compose.nix
        ./services/nas/flatnotes/docker-compose.nix
        ./services/nas/gitea/docker-compose.nix
        ./services/nas/heimdall/docker-compose.nix
        ./services/nas/home-assistant/docker-compose.nix
        ./services/nas/immich/docker-compose.nix
        ./services/nas/jellyfin/docker-compose.nix
        ./services/nas/lubelogger/docker-compose.nix
        ./services/nas/nextcloud/docker-compose.nix
        ./services/nas/planka/docker-compose.nix
        ./services/nas/searxng/docker-compose.nix
        ./services/nas/speedtest/docker-compose.nix
        ./services/nas/unifi/docker-compose.nix
        ./services/nas/vaultwarden/docker-compose.nix
        ./services/vps/dms/docker-compose.nix
        ./services/vps/kuma/docker-compose.nix
      ];
      flake = {...}: let
        specialArgs = {
          inherit inputs;
          inherit (inputs) self;
        };

        # Config generator function
        mkConfigurations = hosts:
          hosts
          # Map each hostname to a name-value pair
          |> map (host: {
            name = host;
            value = inputs.nixpkgs.lib.nixosSystem {
              inherit specialArgs;
              modules = [
                inputs.self.nixosModules."${host}System"
              ];
            };
          })
          # Convert the list of pairs into a single attribute set
          |> builtins.listToAttrs;
      in {
        ######################################################################
        # Generate nixosConfigurations based on helper function and host list
        ######################################################################
        nixosConfigurations = mkConfigurations [
          # Main hosts
          "fw13"
          "nas"
          "vps"
          "retropi"
          # Installation configs
          "install"
          "iso"
          # Testing hosts
          "vivobook"
          "testvm"
        ];
      };
    };
}
