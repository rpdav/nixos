{...}: {
  flake.nixosModules.retroarch = {
    config,
    pkgs,
    ...
  }: {
    # Display Manager
    services.displayManager.autoLogin = {
      enable = true;
      user = config.systemOpts.primaryUser;
    };

    # Retroarch WM
    services.xserver = {
      enable = true;
      displayManager.lightdm.enable = true;
      desktopManager.retroarch = let
        retroarchWithCores = pkgs.retroarch.withCores (cores:
          with cores; [
            bsnes
            dolphin
            melonds
            mupen64plus
            vba-m
          ]);
      in {
        enable = true;
        package = retroarchWithCores;
      };
    };
  };
  flake.homeModules.retroarch = {...}: {
    programs.retroarch = {
      enable = true;
      settings = {
        rgui_browser_directory = "~/Games";
      };
    };
  };
}
