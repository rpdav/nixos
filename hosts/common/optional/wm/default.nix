{
  lib,
  pkgs,
  ...
}: {
  ### Default gnome config
  services.displayManager.gdm = {
    enable = true;
    wayland = true;
  };
  services.desktopManager.gnome.enable = true;

  # Get rid of welcome screen for impermanent systems
  environment.gnome.excludePackages = [
    pkgs.gnome-tour
  ];

  environment.systemPackages = with pkgs; [
    gnome-tweaks
  ];

  # Add cosmic binary cache (needed when building cosmic on gnome specialisation)
  nix.settings = {
    substituters = ["https://cosmic.cachix.org/"];
    trusted-public-keys = ["cosmic.cachix.org-1:Dya9IyXD4xdBehWjrkPv6rtxpmMdRel02smYzA85dPE="];
  };

  ### Cosmic specialization
  specialisation.cosmic.configuration = {
    inputs,
    lib,
    ...
  }: {
    imports = [inputs.nixos-cosmic.nixosModules.default];

    # Enable cosmic
    services.desktopManager.cosmic.enable = true;
    services.displayManager.cosmic-greeter.enable = true;

    # Disable gnome
    services.displayManager.gdm.enable = lib.mkForce false;
    services.desktopManager.gnome.enable = lib.mkForce false;
  };
}
