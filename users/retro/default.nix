{
  inputs,
  self,
  ...
}: {
  flake.nixosModules.user-retro = {config, ...}:
  ## This file contains all NixOS config for user retro
  {
    # user--specific variable overrides
    userOpts.theme = "retroarch";
    userOpts.cursor = "Bibata-Modern-Ice";
    userOpts.cursorPkg = "bibata-cursors";

    # user definition
    # this is an unprivileged kiosk account
    users.mutableUsers = false;
    sops.secrets."passwordHashRetro" = {
      neededForUsers = true;
      sopsFile = "${inputs.nix-secrets.outPath}/retro.yaml";
    };
    users.users.retro = {
      hashedPasswordFile = config.sops.secrets."passwordHashRetro".path;
      isNormalUser = true;
      home = "/home/retro";
    };

    # home-manager config
    home-manager = {
      useUserPackages = true;
      users.retro = self.homeModules."retro@${config.networking.hostName}";
    };

    # Fix file permissions after backup restore
    systemd.tmpfiles.rules = [
      # make all files in home directory owned by user
      "Z ${config.systemOpts.persistVol}/home/retro - retro users"
      # make user's home directory not readable by others
      "z ${config.systemOpts.persistVol}/home/retro 0700 retro users"
    ];
  };
  flake.homeModules.user-retro = {
    home.username = "retro";
  };
}
