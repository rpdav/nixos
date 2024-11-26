{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./bash.nix
    ./git.nix
    ./sops.nix
    ./ssh.nix
    ./vim.nix
  ];

  home.packages = with pkgs; [
    tree
    fastfetch
    just

    # scripts
    (import ../optional/scripts/fs-diff.nix {inherit pkgs;})
  ];
}
