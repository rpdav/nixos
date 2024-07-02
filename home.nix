{ config, pkgs, impermanence, nur, ... }:

let
  nur-no-pkgs = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {};
in {
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "ryan";
  home.homeDirectory = "/home/ryan";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "24.05"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = [
    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # pkgs.hello

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # Desktop  Documents  Downloads  Music  Pictures  Public  Templates  Videos
    # "Desktop".source = "/persist/home/ryan/Desktop";
    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # Impermanence: see configuration.nix. Couldn't get it to work here :\


  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/ryan/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    # EDITOR = "emacs";
  };

  programs.bash = {
    enable = true;
    shellAliases = {
      ".." = "cd ..";
      ll = "ls -la";
      nix-switch = "sudo nixos-rebuild switch --flake /home/ryan/.nixops";
    };
  };

  programs.git = {
    enable = true;
    userName = "ryan";
    userEmail = "***REMOVED***";
    extraConfig = {
      init.defaultBranch = "main";
    };
  };

#  programs.vscode.enable = true;

  programs.ssh = {
    enable = true;
    userKnownHostsFile = "/persist/home/ryan/.ssh/known_hosts";
  };

  programs.bash.historyFile = "/persist/home/ryan/.bash_history";

  programs.firefox = {
    enable = true;
    profiles.ryan = {
	  id = 0;
	  name = "ryan default";
	  settings = {
	    "browser.startup.homepage" = "https://start.***REMOVED***";
	    "browser.search.region" = "US";
	    "browser.search.isUS" = true;
	    "extensions.autoDisableScopes" = 0; #automatically enable added extensions
	    "doh-rollout.disable-heuristics" = true; #disable DoH
	    "doh-rollout.skipHeuristicsCheck" = true; #disable DoH
	    "doh-rollout.doneFirstRun" = true; #these 3 doh-rollout options don't seem to work
	    "signon.rememberSignons" = false; #disable password storage
	    "dom.security.https_only_mode" = true;
	    "extensions.formautofill.addresses.enabled" = false; #disable address autofill
	    "extensions.formautofill.creditCards.enabled" = false; #disable payment autofill	    
	  };
	  ## these need added to flake to work
	  extensions = with pkgs.nur.repos.rycee.firefox-addons; [
	   bitwarden
           ublock-origin 
	  ];
	  search = {
	    force = true;
	    default = "DuckDuckGo";
	    engines = {
		  "Nix Packages" = {
			urls = [{
			  template = "https://search.nixos.org/packages";
			  params = [
				{ name = "type"; value = "packages"; }
				{ name = "query"; value = "{searchTerms}"; }
			  ];
			}];
			icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
			definedAliases = [ "@np" ];
		  };
		  "MyNixOS" = {
			urls = [{
			  template = "https://mynixos.com/search";
			  params = [
				{ name = "q"; value = "{searchTerms}"; }
			  ];
			}];
			iconUpdateURL = "https://mynixos.com/favicon.png";
			definedAliases = [ "@mn" ];
		  };
		};
	    order = [ "DuckDuckGo" "Google" "Nix Packages" "MyNixOS" ];
	  };
	};
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}

