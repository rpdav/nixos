# Got this from EmergentMind - see https://unmovedcentre.com/posts/improving-qol-on-nixos-with-yubikey/ for full guide to set up
# This module makes use of a custom option `config.systemOpts.primaryUser`.
# This can be substituted with a hard-coded user.
{
  flake.modules.nixos.yubikey = {
    config,
    pkgs,
    lib,
    ...
  }: let
    homeDirectory = "/home/${config.systemOpts.primaryUser}";
    yubikey-up = let
      yubikeyIds = lib.concatStringsSep " " (
        lib.mapAttrsToList (name: id: "[${name}]=\"${toString id}\"") config.yubikey.identifiers
      );
    in
      pkgs.writeShellApplication {
        name = "yubikey-up";
        runtimeInputs = builtins.attrValues {inherit (pkgs) gawk yubikey-manager;};
        text = ''
          #!/usr/bin/env bash
          set -euo pipefail

          serial=$(ykman list | awk '{print $NF}')
          # If it got unplugged before we ran, just don't bother
          if [ -z "$serial" ]; then
            exit 0
          fi

          declare -A serials=(${yubikeyIds})

          key_name=""
          for key in "''${!serials[@]}"; do
            if [[ $serial == "''${serials[$key]}" ]]; then
              key_name="$key"
            fi
          done

          if [ -z "$key_name" ]; then
            echo WARNING: Unidentified yubikey with serial "$serial" . Won\'t link an SSH key.
            exit 0
          fi

          echo "Creating links to ${homeDirectory}/id_$key_name"
          ln -sf "${homeDirectory}/.ssh/id_$key_name" ${homeDirectory}/.ssh/id_yubikey
          ln -sf "${homeDirectory}/.ssh/id_$key_name.pub" ${homeDirectory}/.ssh/id_yubikey.pub
        '';
      };
    yubikey-down = pkgs.writeShellApplication {
      name = "yubikey-down";
      text = ''
        #!/usr/bin/env bash
        set -euo pipefail

        rm ${homeDirectory}/.ssh/id_yubikey
        rm ${homeDirectory}/.ssh/id_yubikey.pub
      '';
    };
  in {
    options = {
      yubikey = {
        enable = lib.mkEnableOption "Enable yubikey support";
        identifiers = lib.mkOption {
          default = {};
          type = lib.types.attrsOf lib.types.int;
          description = "Attrset of Yubikey serial numbers";
          example = lib.literalExpression ''
            {
              foo = 12345678;
              bar = 87654321;
            }
          '';
        };
      };
    };
    config = lib.mkIf config.yubikey.enable {
      environment.systemPackages = lib.flatten [
        (builtins.attrValues {
          inherit
            (pkgs)
            yubioath-flutter # gui-based authenticator tool. yubioath-desktop on older nixpkg channels
            yubikey-manager # cli-based authenticator tool. accessed via `ykman`
            pam_u2f # for yubikey with sudo
            ;
        })
        yubikey-up
        yubikey-down
      ];

      # Create ssh files
      # Yubikey 4/5 U2F+CCID
      # SUBSYSTEM == "usb", ATTR{idVendor}=="1050", ENV{ID_SECURITY_TOKEN}="1", GROUP="wheel"
      # We already have a yubikey rule that sets the ENV variable
      services.udev.extraRules = ''
        # Link/unlink ssh key on yubikey add/remove
        SUBSYSTEM=="usb", ACTION=="add", ATTR{idVendor}=="1050", RUN+="${lib.getBin yubikey-up}/bin/yubikey-up"
        SUBSYSTEM=="hid", ACTION=="remove", ENV{HID_NAME}=="Yubico Yubi*", RUN+="${lib.getBin yubikey-down}/bin/yubikey-down"
      '';

      # Yubikey required services and config. See Dr. Duh NixOS config for reference
      services.pcscd.enable = true; # smartcard service
      services.udev.packages = [pkgs.yubikey-personalization];

      # yubikey login / sudo
      security.pam = {
        sshAgentAuth.enable = true;
        rssh = {
          enable = true;
          settings.auth_key_file = "/etc/ssh/authorized_keys.d/\${user}";
        };
        u2f = {
          enable = true;
          settings = {
            cue = true; # Tells user they need to press the button
            authFile = "${homeDirectory}/.config/Yubico/u2f_keys";
          };
        };
        services = {
          login.u2fAuth = true;
          sudo = {
            u2fAuth = true;
            sshAgentAuth = true; # Use SSH_AUTH_SOCK for sudo
            rssh = true;
          };
          polkit-1.rssh = true;
        };
      };
    };
  };
}
