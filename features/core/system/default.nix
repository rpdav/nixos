{
  inputs,
  self,
  ...
}: {
  flake.nixosModules.core = {
    pkgs,
    config,
    ...
  }: let
    inherit (config) systemOpts;
  in {
    ## This file contains NixOS configuration common to all hosts

    imports = [
      self.nixosModules.opts
      self.nixosModules.home-manager
      inputs.disko.nixosModules.disko
      self.nixosModules.nix
    ];

    environment.variables = {
      EDITOR = "nvim";
    };

    # Base fonts
    fonts = {
      packages = with pkgs; [
        noto-fonts
      ];
      fontconfig.enable = true;
    };

    # Allow local users to inhibit sleep (used for some systemd user units)
    security.polkit = {
      enable = true;
      extraConfig = ''
        polkit.addRule(function(action, subject) {
            if (action.id == "org.freedesktop.login1.inhibit-block-shutdown" &&
            subject.isInGroup("users"))
                return polkit.Result.YES;
        });
      '';
    };

    # CLI config
    programs.bash.completion.enable = true;
    environment.enableAllTerminfo = true;

    # Time
    time.timeZone = "America/Indiana/Indianapolis";
  };
}
