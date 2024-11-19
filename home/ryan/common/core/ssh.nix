{config, pkgs, lib, userSettings, ... }:

let
  # Path to public keys stored in config
  pathtokeys  = ../../../../hosts/common/users/${userSettings.username}/keys;
  # List of public keys in path
  yubikeys =
    lib.lists.forEach (builtins.attrNames (builtins.readDir pathtokeys))
      # Remove the .pub suffix
      (key: lib.substring 0 (lib.stringLength key - lib.stringLength ".pub") key);
  # Create set of keys to be symlinked by home.file
  yubikeyPublicKeyEntries = lib.attrsets.mergeAttrsList (
    lib.lists.map
      # list of dicts
      (key: { ".ssh/${key}.pub".source = "${pathtokeys}/${key}.pub"; })
      yubikeys
  );
in
  {
    # Pull private keys from sops
    sops.secrets = {
      "${userSettings.username}/sshKeys/id_ed25519".path = "/home/${userSettings.username}/.ssh/id_ed25519";
      "${userSettings.username}/sshKeys/id_yubi5c".path = "/home/${userSettings.username}/.ssh/id_yubi5c";
      "${userSettings.username}/sshKeys/id_yubi5pink".path = "/home/${userSettings.username}/.ssh/id_yubi5pink";
    };

    # General ssh config
    programs.ssh = {
      enable = true;
      extraConfig = ''
        Host nas
        	HostName 10.10.1.17
        	User root
        	Port 22
        
        Host pi
        	HostName 10.10.1.10
        	User pi
        	Port 22
        
        Host vps
        	HostName 10.100.94.1 #wireguard IP
        	User root
        	Port 44422
        
        Host pve
        	Hostname 10.10.1.18
        	User root
        	Port 22
  
        Host borg
          Hostname 10.10.1.16
          User borg

        # req'd for enabling yubikey-agent
        AddKeysToAgent yes
      '';

      matchBlocks = {
        "git" = {
          host = "gitea.dfrp.xyz github.com";
          user = "git";
          identityFile = [
            "~/.ssh/id_yubikey" # This is an auto symlink to whatever yubikey is plugged in. See hosts/common/optional/yubikey
           "~/.ssh/id_ed25519" # fallback if yubis aren't present
          ];
       };
        "servers" = {
          host = "nas pi vps pve borg";
          identityFile = [
            "~/.ssh/id_yubikey" # This is an auto symlink to whatever yubikey is plugged in. See hosts/common/optional/yubikey
           "~/.ssh/id_ed25519" # fallback if yubis aren't present
          ];
        };
      };
    };
    # symlink public keys
    home.file = {
    ".ssh/sockets/.keep".text = "# Managed by Home Manager";
    } // yubikeyPublicKeyEntries;
  }
