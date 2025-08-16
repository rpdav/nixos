{...}: {
  imports = [
    ./git.nix
  ];
  programs.lazydocker = {
    enable = true;
    settings = {
      gui.returnImmediately = true;
    };
  };
}
