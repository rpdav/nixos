{
  systemOpts,
  userOpts,
  ...
}: let
  # Define appropriate key path depending on whether system is impermanent
  defaultLocation = "/home/${userOpts.username}/.bash_history";
  historyFile =
    if systemOpts.impermanent
    then "${systemOpts.persistVol}/${defaultLocation}"
    else "${defaultLocation}";
in {
  programs.bash = {
    inherit historyFile;
    enable = true;
    enableCompletion = true;
    shellAliases = {
      ".." = "cd ..";
      ll = "ls -la";
      sudo = "sudo "; #allows aliases with sudo
      jctl = "journalctl -xeu";
      nas-boot = "ssh root@nas -p 2220 cryptsetup-askpass";
      ## git
      gs = "git status";
      vim = "nvim";
      gc = "git commit -am";
      gp = "git push";
      lg = "lazygit";
      ## docker
      compose2nix = "nix run github:aksiksi/compose2nix --";
      ld = "lazydocker";
      ## system admin
      sctl = "systemctl-tui";
    };
    bashrcExtra = ''
      # this is overridden if stylix is used
      force_color_prompt=yes
      PS1='\[\033[1;36m\]\u\[\033[1;31m\]@\[\033[1;32m\]\h:\[\033[1;35m\]\w\[\033[1;31m\]\$\[\033[0m\] '
    '';
  };

  programs.autojump.enable = true;

  #  programs.starship = {
  #    enable = true;
  #    settings = {
  #      settings = pkgs.lib.importTOML ./starship.toml;
  #    };
  #  };
}
