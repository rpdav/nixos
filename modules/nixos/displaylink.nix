{
  flake.modules.nixos.displaylinkConsole = {
    config,
    lib,
    pkgs,
    ...
  }: let
    cfg = config.services.displaylinkConsole;

    displaylink = pkgs.displaylink.overrideAttrs (_old: {
      src = pkgs.fetchurl {
        inherit (cfg.src) name url hash;
        curlOptsList = ["--referer" "https://www.synaptics.com/"];
      };
    });

    # Block cage until DLM has an evdi connector in "connected" state.
    waitForOutput = pkgs.writeShellApplication {
      name = "wait-for-displaylink";
      runtimeInputs = [pkgs.coreutils];
      text = ''
        for _ in $(seq 1 60); do
          for c in /sys/class/drm/card*-*; do
            case "$(readlink -f "$c")" in
              */platform/evdi.*/*) ;;
              *) continue ;;
            esac
            [ "$(cat "$c/status")" = connected ] && exit 0
          done
          sleep 1
        done
        echo "no DisplayLink output appeared" >&2
        exit 1
      '';
    };

    console = pkgs.writeShellScript "displaylink-console" ''
      exec ${lib.getExe pkgs.foot} --font="${cfg.font}" \
        /run/wrappers/bin/su -l ${cfg.loginUser}
    '';
  in {
    options.services.displaylinkConsole = {
      enable = lib.mkEnableOption "host console on a DisplayLink adapter";

      acceptEula = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Confirm you accept the DisplayLink/Synaptics software EULA.";
      };

      loginUser = lib.mkOption {
        type = lib.types.str;
        description = "Account the console `su`s into (needs a password).";
      };

      font = lib.mkOption {
        type = lib.types.str;
        default = "JetBrainsMono Nerd Font:size=12";
      };

      src = {
        name = lib.mkOption {
          type = lib.types.str;
          default = "displaylink-620.zip";
        };
        url = lib.mkOption {
          type = lib.types.str;
          default = "https://www.synaptics.com/sites/default/files/exe_files/2025-09/DisplayLink%20USB%20Graphics%20Software%20for%20Ubuntu6.2-EXE.zip";
        };
        hash = lib.mkOption {
          type = lib.types.str;
          description = "SRI hash of the zip (see nix store prefetch-file).";
        };
        versionPrefix = lib.mkOption {
          type = lib.types.str;
          default = "6.2";
          description = "Must prefix pkgs.displaylink.version; guards against nixpkgs/zip mismatch.";
        };
      };
    };

    config = lib.mkIf cfg.enable {
      assertions = [
        {
          assertion = cfg.acceptEula;
          message = "services.displaylinkConsole: set acceptEula = true after reading the DisplayLink EULA.";
        }
        {
          assertion = lib.hasPrefix cfg.src.versionPrefix pkgs.displaylink.version;
          message = ''
            services.displaylinkConsole: nixpkgs displaylink is ${pkgs.displaylink.version} but the
            pinned zip is ${cfg.src.versionPrefix}.x. Update src.url/src.hash/src.name/src.versionPrefix.
          '';
        }
      ];

      # --- kernel side: virtual DRM device, one pre-created ---
      boot.extraModulePackages = [config.boot.kernelPackages.evdi];
      boot.kernelModules = ["evdi"];
      boot.extraModprobeConfig = "options evdi initial_device_count=1";

      # Stable name for the evdi card + start DLM when the adapter appears
      services.udev.extraRules = ''
        SUBSYSTEM=="drm", KERNEL=="card[0-9]*", SUBSYSTEMS=="platform", KERNELS=="evdi.*", SYMLINK+="dri/evdi"
        ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="17e9", TAG+="systemd", ENV{SYSTEMD_WANTS}+="dlm.service"
      '';

      # --- DisplayLink Manager ---
      systemd.services.dlm = {
        description = "DisplayLink Manager";
        wantedBy = ["multi-user.target"];
        after = ["systemd-modules-load.service" "systemd-udevd.service"];
        serviceConfig = {
          ExecStart = lib.getExe' displaylink "DisplayLinkManager";
          Restart = "always";
          RestartSec = 3;
          StateDirectory = "displaylink";
          LogsDirectory = "displaylink";
          WorkingDirectory = "/var/lib/displaylink";
        };
      };

      # --- console: cage + foot on tty1, unprivileged kiosk user ---
      users.users.kiosk = {
        isNormalUser = true;
        description = "DisplayLink console kiosk";
      };

      fonts.packages = [pkgs.nerd-fonts.jetbrains-mono];

      services.cage = {
        enable = true;
        user = "kiosk";
        program = "${console}";
        environment = {
          WLR_RENDERER = "pixman";
          WLR_DRM_DEVICES = "/dev/dri/evdi";
          WLR_NO_HARDWARE_CURSORS = "1";
        };
      };

      systemd.services."cage-tty1" = {
        after = ["dlm.service"];
        wants = ["dlm.service"];
        serviceConfig = {
          ExecStartPre = [(lib.getExe waitForOutput)];
          # Auto-restart if session is closed cleanly
          Restart = "on-success";
          RestartSec = 5;
        };
      };
    };
  };
}
