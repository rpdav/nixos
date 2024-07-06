{ config, pkgs, impermanence, nur, secrets, ... }:

let
  nur-no-pkgs = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {};
in {
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

  home.packages = with pkgs [
    protonmail-bridge-gui
  ];

  # Impermanence: see configuration.nix. Couldn't get it to work here :\


  home.sessionVariables = {
    EDITOR = "vim";
  };

  programs.bash = {
    enable = true;
    shellAliases = {
      ".." = "cd ..";
      ll = "ls -la";
      nix-switch = "sudo nixos-rebuild switch --flake /home/ryan/.nixops";
      rebuild = "bash ~/scripts/rebuild.sh";
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

  programs.vim = {
    enable = true;
    settings = {
      mouse = "a";
      number = true;
      relativenumber = true;
      tabstop = 2;
    };
    extraConfig =
    ''
      set autoindent
      set smartindent
    '';
  };

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
     metamask
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

  ## can't get this to work
  accounts.calendar = {
    basePath = ".calendar";
    accounts.nextcloud = {
      primary = true;
      name = "nextcloud";
      remote = {
        type = "caldav";
        url = "https://cloud.***REMOVED***/remote.php/dav/";
        userName = "ryan";
        passwordCommand = "echo ${secrets.calendar.password}";
      };
    };
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}

