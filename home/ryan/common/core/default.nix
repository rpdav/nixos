{
  secrets,
  pkgs,
  userOpts,
  ...
}: {
  imports = [
    ./bash.nix
    ./git.nix
    ./sops.nix
    ./ssh.nix
    ./vim
  ];

  home.packages = with pkgs; [
    tree
    gdu
    fastfetch
    just

    # scripts
    (import ../optional/scripts/fs-diff.nix {inherit pkgs;})
    (import ../optional/scripts/clear-testbox.nix {inherit pkgs;})
    (import ../optional/scripts/clear-testvm.nix {inherit pkgs;})
    (import ../optional/scripts/clear-vps.nix {inherit pkgs;})
    (import ../optional/scripts/lish.nix {inherit pkgs; inherit secrets;})
  ];

  home.sessionVariables = {
    EDITOR = userOpts.editor;
  };
}
