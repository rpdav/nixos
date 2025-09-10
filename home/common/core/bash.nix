{
  config,
  osConfig,
  pkgs,
  ...
}: let
  inherit (pkgs) bat eza fzf git lazygit lazydocker systemctl-tui;
  # Define appropriate key path depending on whether system is impermanent
  defaultLocation = "${config.home.homeDirectory}/.bash_history";
  historyFile =
    if osConfig.systemOpts.impermanent
    then "${config.systemOpts.persistVol}${defaultLocation}"
    else defaultLocation;
in {
  programs.bash = {
    inherit historyFile;
    enable = true;
    enableCompletion = true;
    shellAliases = {
      # general
      ".." = "cd ..";
      ls = "${eza}/bin/eza -lh --group-directories-first --icons=auto";
      lsa = "ls -a";
      lt = "${eza}/bin/eza --tree --level=2 --long --icons --git";
      lta = "lt -a";
      ff = "${fzf}/bin/fzf --preview '${bat}/bin/bat --style=numbers --color=always {}'";
      sudo = "sudo "; #allows aliases with sudo
      cat = "${bat}/bin/bat --paging=never";
      nas-boot = "ssh root@nas -p 2220 cryptsetup-askpass";
      # git
      gs = "${git}/bin/git status";
      gc = "${git}/bin/git commit -am";
      gp = "${git}/bin/git push";
      lg = "${lazygit}/bin/lazygit";
      # docker
      ld = "${lazydocker}/bin/lazydocker";
      # system admin
      sctl = "${systemctl-tui}/bin/systemctl-tui";
      jctl = "journalctl -xeu";
      jctlu = "journalctl --user -xeu";
      na = "nixos apply";
      ng = "nixos generation";
    };
    bashrcExtra = ''
      # this is overridden if stylix is used
      force_color_prompt=yes
      PS1='\[\033[1;36m\]\u\[\033[1;31m\]@\[\033[1;32m\]\h:\[\033[1;35m\]\w\[\033[1;31m\]\$\[\033[0m\] '
    '';
  };
}
