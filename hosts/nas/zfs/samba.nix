{
  pkgs,
  lib,
  config,
  ...
}: {
  # Enable Samba and helper services
  services = {
    samba = {
      enable = true;
      package = pkgs.samba4Full;
      # ^^ `samba4Full` is compiled with avahi, ldap, AD etc support (compared to the default package, `samba`
      # Required for samba to register mDNS records for auto discovery
      # See https://github.com/NixOS/nixpkgs/blob/592047fc9e4f7b74a4dc85d1b9f5243dfe4899e3/pkgs/top-level/all-packages.nix#L27268
      openFirewall = true;
      settings = {
        gobal = {
          "server smb encrypt" = "required";
          # ^^ Note: Breaks `smbclient -L <ip/host> -U%` by default, might require the client to set `client min protocol`?
          "server min protocol" = "SMB3_00";
        };
        backups = {
          path = "/mnt/storage/backups";
          "read only" = "no";
          browseable = "yes";
          writeable = "no";
          "read list" = "";
          "write list" = "ryan";
          "valid users" = "ryan";
        };
      };
    };
    avahi = {
      publish.enable = true;
      publish.userServices = true;
      # ^^ Needed to allow samba to automatically register mDNS records (without the need for an `extraServiceFile`
      nssmdns4 = true;
      # ^^ Not one hundred percent sure if this is needed- if it aint broke, don't fix it
      enable = true;
      openFirewall = true;
    };
    samba-wsdd = {
      # This enables autodiscovery on windows since SMB1 (and thus netbios) support was discontinued
      enable = true;
      openFirewall = true;
    };
  };

  # Create impermanent directory
  environment.persistence.${config.systemOpts.persistVol} = lib.mkIf config.systemOpts.impermanent {
    directories = [
      "/var/lib/samba"
    ];
  };

  #imperative: I have not been able to get reproducible setup of samba users to work.
  # The code below causes rebuild/reboot to hang on `setting up /etc...`
  # Samba users are currently managed by persisting /var/lib/samba above and
  # imperatively setting up users using `sudo smbpasswd -a username

  #  sops.secrets."ryan/smbPass" = {};
  #
  #  system.activationScripts = {
  #    sambaUserSetup = {
  #      text = ''
  #        PATH=$PATH:${lib.makeBinPath [pkgs.samba]}
  #	IFS= read -r password ${config.sops.secrets."ryan/smbPass".path}
  #	printf '%s\n%s\n' "$password" "$password" | smbpasswd -a -s ${username}
  #      '';
  #      deps = [];
  #    };
  #  };
}
