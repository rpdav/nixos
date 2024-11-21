{config, lib, inputs, secrets, pkgs-stable, ...}:
## This file contains all NixOS config for user ryan

let
  # Generates a list of the keys in ./keys
  pubKeys = lib.filesystem.listFilesRecursive ./keys;
in
{

  # user--specific variable overrides
  userSettings.theme = lib.mkForce "snowflake-blue";
  userSettings.base16theme = lib.mkForce "3024"; 

  # user definition
  users.mutableUsers = false;
  sops.secrets."ryan/passwordhash".neededForUsers = true;

  users.users.ryan = {
    hashedPasswordFile = config.sops.secrets."ryan/passwordhash".path;
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    home = "/home/ryan"; # Setting this to point local backup to persisted home directory. Not sure this will actually work

    # These get placed into /etc/ssh/authorized_keys.d/<name> on nixos hosts
    openssh.authorizedKeys.keys = lib.lists.forEach pubKeys (key: builtins.readFile key);
  };

  # home-manager config
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.ryan = import ../../../../home/ryan/${config.networking.hostName}.nix;
    sharedModules = [ 
      (import ../../../../modules/home-manager)
      inputs.plasma-manager.homeManagerModules.plasma-manager 
      inputs.impermanence.nixosModules.home-manager.impermanence
    ];
    extraSpecialArgs = {
      inherit pkgs-stable;
      inherit secrets;
      inherit inputs;
    };
  };
}
