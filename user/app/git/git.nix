{ config, pkgs, ... }:

{

  programs.git = {
    enable = true;
    userName = "ryan";
    userEmail = "${secrets.personal-mail.address}";
    extraConfig = {
      init.defaultBranch = "main";
    };
  };

}
