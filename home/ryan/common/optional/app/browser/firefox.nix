{
  config,
  pkgs,
  inputs,
  systemOpts,
  secrets,
  ...
}: {
  programs.firefox = {
    enable = true;
    profiles.ryan = {
      id = 0;
      name = "ryan default";
      settings = {
        "browser.startup.homepage" = "https://start.${secrets.selfhosting.domain}";
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

      # Extensions
      extensions = with inputs.firefox-addons.packages."${systemOpts.arch}"; [
        bitwarden
        ublock-origin
        metamask
      ];

      # Search engines
      search = {
        force = true;
        default = "DuckDuckGo";
        engines = {
          "Nix Packages" = {
            urls = [
              {
                template = "https://search.nixos.org/packages";
                params = [
                  {
                    name = "type";
                    value = "packages";
                  }
                  {
                    name = "query";
                    value = "{searchTerms}";
                  }
                ];
              }
            ];
            icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = ["@np"];
          };
          "MyNixOS" = {
            urls = [
              {
                template = "https://mynixos.com/search";
                params = [
                  {
                    name = "q";
                    value = "{searchTerms}";
                  }
                ];
              }
            ];
            iconUpdateURL = "https://mynixos.com/favicon.png";
            definedAliases = ["@mn"];
          };
          "Wikipedia" = {
            urls = [
              {
                template = "https://en.wikipedia.org/wiki/Special:Search";
                params = [
                  {
                    name = "search";
                    value = "{searchTerms}";
                  }
                ];
              }
            ];
            iconUpdateURL = "https://mynixos.com/favicon.png";
            definedAliases = ["@wik"];
          };
        };
        order = ["DuckDuckGo" "Google" "Nix Packages" "MyNixOS" "Wikipedia"];
      };
    };
  };
}
