{
  systemSettings,
  ...
}: {
  ## This file contains NixOS configuration common to all hosts

  imports = [
    ./tailscale.nix
    ./packages.nix
    ./sops.nix
    ./sshd.nix #needed for sops keys
  ];

  # Enable flakes
  nix = {
    extraOptions = ''
      experimental-features = nix-command flakes
      keep-outputs = true
      keep-derivations = true
    '';
  };

  # Automate garbage collection
  nix.gc = {
    automatic = true;
    dates = systemSettings.gcInterval;
    options = "--delete-older-than ${systemSettings.gcRetention}";
    };

  # CLI config
  services.nixos-cli.enable = true;
  programs.bash.completion.enable = true;

  # Time
  time.timeZone = systemSettings.timezone;
}
