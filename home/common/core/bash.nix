{
  config,
  osConfig,
  pkgs,
  ...
}: let
  inherit (pkgs) bat git lazygit lazydocker systemctl-tui;
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
      ".." = "cd ..";
      ll = "ls -la";
      sudo = "sudo "; #allows aliases with sudo
      cat = "${bat}/bin/bat --paging=never";
      jctl = "journalctl -xeu";
      jctlu = "journalctl --user -xeu";
      nas-boot = "ssh root@nas -p 2220 cryptsetup-askpass";
      vim = "nvim";
      ## git
      gs = "${git}/bin/git status";
      gc = "${git}/bin/git commit -am";
      gp = "${git}/bin/git push";
      lg = "${lazygit}/bin/lazygit";
      ## docker
      compose2nix = "nix run github:aksiksi/compose2nix --";
      ld = "${lazydocker}/bin/lazydocker";
      ## system admin
      sctl = "${systemctl-tui}/bin/systemctl-tui";
    };
    bashrcExtra = ''
      # this is overridden if stylix is used
      force_color_prompt=yes
      PS1='\[\033[1;36m\]\u\[\033[1;31m\]@\[\033[1;32m\]\h:\[\033[1;35m\]\w\[\033[1;31m\]\$\[\033[0m\] '
    '';
  };
}
