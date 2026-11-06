{
  flake.nixosModules.core = {
    config,
    lib,
    pkgs,
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
}
