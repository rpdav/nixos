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
    ./starship.nix
    ./tmux
  ];

  home.packages = with pkgs; [
    tree
    gdu
    fastfetch
    just

    # scripts
    (import ../optional/scripts/fs-diff.nix {inherit pkgs;})
    (import ../optional/scripts/clear-testbox.nix {
      inherit pkgs;
      inherit userOpts;
    })
    (import ../optional/scripts/clear-testvm.nix {
      inherit pkgs;
      inherit userOpts;
    })
    (import ../optional/scripts/clear-vps.nix {
      inherit pkgs;
      inherit userOpts;
    })
    (import ../optional/scripts/lish.nix {
      inherit pkgs;
      inherit secrets;
    })
  ];
  programs.bat.enable = true;

  programs.autojump.enable = true;

  programs.btop.enable = true;

  programs.ripgrep.enable = true;

  home.sessionVariables = {
    EDITOR = userOpts.editor;
  };
}
