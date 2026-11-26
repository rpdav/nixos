{
  flake.nixosModules.core = {
    config,
    lib,
    ...
  }: let
    inherit (config) systemOpts;
  in {
    # Create impermanent directory
    environment.persistence.${systemOpts.persistVol} = lib.mkIf systemOpts.impermanent {
      files = [
        "/etc/ssh/ssh_host_ed25519_key"
        "/etc/ssh/ssh_host_ed25519_key.pub"
      ];
    };

    # Github repos
    programs.ssh.knownHosts."github.com".publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";

    # Enable SSH
    services.openssh = {
      enable = true;
      ports = [22];
      settings.PasswordAuthentication = false;
      hostKeys = [
        {
          comment = "server key";
          path = "/etc/ssh/ssh_host_ed25519_key";
          rounds = 100;
          type = "ed25519";
        }
      ];
    };

    programs.ssh.extraConfig = ''
      Host nas
        User ryan

      Host vps
        User ryan

      Host retropi
        User ryan

      Host gitea.dfrp.xyz
        User git
        Port 2223

      Host github.com
        User git
    '';
  };
  flake.homeModules.core = {
    config,
    osConfig,
    ...
  }: let
    inherit (config.home) homeDirectory username;
    # Function to symlink user's authorized pub keys from host config into ~/.ssh
    pubKeys = osConfig.users.users.${username}.openssh.authorizedKeys.keyFiles;
    keyToAttribute = path: let
      pathString = toString path;
      filename = baseNameOf pathString;
    in {
      name = filename;
      value = {
        source = path;
        target = ".ssh/${filename}";
      };
    };
    homeFileConfig = builtins.listToAttrs (map keyToAttribute pubKeys);
  in {
    # General ssh config
    programs.ssh = {
      enable = true;
      enableDefaultConfig = false; #this will eventually be deprecated and can be removed
      settings."*" = {
        userKnownHostsFile = "${osConfig.systemOpts.persistVol}${homeDirectory}/.ssh/known_hosts";
        serverAliveInterval = 0;
        serverAliveCountMax = 3;
        compression = false;
        hashKnownHosts = false;
      };
    };

    # Pull manual key from sops
    # This gets overridden by the yubikey module if it's in use
    sops.secrets = {
      "sshKeys/id_ed25519".path = "${homeDirectory}/.ssh/id_manual";
    };

    # symlink public keys from osConfig
    home.file = homeFileConfig;
  };
}
