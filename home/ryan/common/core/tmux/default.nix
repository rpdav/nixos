{pkgs, ...}: {
  programs.tmux = {
    enable = true;
    keyMode = "vi";
    plugins = with pkgs; [
      tmuxPlugins.better-mouse-mode
    ];
    tmuxp.enable = true;
  };
}
