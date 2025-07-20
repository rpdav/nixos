{
  inputs,
  config,
  ...
}: let
  inherit (config) systemOpts;
in {
  ## This file contains NixOS configuration common to all hosts

  imports = [
    ./tailscale.nix
    ./packages.nix
    ./sops.nix
    ./sshd.nix #needed for sops keys
    ./vim.nix

    inputs.disko.nixosModules.disko
  ];

  # Enable flakes
  nix = {
    extraOptions = ''
      experimental-features = nix-command flakes pipe-operators
      keep-outputs = true
      keep-derivations = true
      warn-dirty = false
    '';
  };

  # Automate garbage collection
  nix.gc = {
    automatic = true;
    dates = systemOpts.gcInterval;
    options = "--delete-older-than ${systemOpts.gcRetention}";
  };

  # Backup config
  backupOpts = {
    localRepo = "ssh://borg@borg:2222/backup";
    remoteRepo = "/mnt/B2/borg";
    #TODO move this to pattern file? it's not used in HM
    sourceDirectories = [
      "${systemOpts.persistVol}/etc/NetworkManager"
      "${systemOpts.persistVol}/etc/ssh"
      "${systemOpts.persistVol}/root"
    ];
    patterns = [
      # Run `borg help patterns` for guidance on exclusion patterns
      "- */var/**" #not needed for restore
      "- **/.Trash*" #automatically made by gui deletions
      "- **/libvirt" #vdisks made mostly for testing
    ];
  };

  # CLI config
  programs.bash.completion.enable = true;
  environment.enableAllTerminfo = true;

  # Time
  time.timeZone = "America/Indiana/Indianapolis";
}
