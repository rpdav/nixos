{
  pkgs,
  config,
  osConfig,
  inputs,
  lib,
  secrets,
  ...
}: let
  inherit (osConfig) systemOpts;
  domain = secrets.selfhosting.domain;
in {
  # Create persistent directories
  home.persistence."${systemOpts.persistVol}${config.home.homeDirectory}" = lib.mkIf systemOpts.impermanent {
    directories = [
      ".mozilla"
    ];
  };
  programs.firefox = {
    enable = true;
    profiles.ryan = {
      id = 0;
      name = "ryan default";
      settings = {
        "browser.startup.homepage" = "https://start.${domain}";
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
      extensions.packages = with inputs.firefox-addons.packages."${pkgs.system}"; [
        bitwarden
        ublock-origin
        metamask
      ];

      # Search engines
      search = {
        force = true;
        default = "SearX";
        engines = {
          "SearX" = {
            urls = [
              {
                template = "https://search.${secrets.selfhosting.domain}";
                params = [
                  {
                    name = "q";
                    value = "{searchTerms}";
                  }
                ];
              }
            ];
            icon = "https://search.${domain}/favicon.ico";
            definedAliases = ["@s"];
          };
          "Nixos Options" = {
            urls = [
              {
                template = "https://search.nixos.org/options";
                params = [
                  {
                    name = "channel";
                    value = "unstable";
                  }
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
            definedAliases = ["@no"];
          };
          "Nix Packages" = {
            urls = [
              {
                template = "https://search.nixos.org/packages";
                params = [
                  {
                    name = "channel";
                    value = "unstable";
                  }
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
          "Home-Manager Options" = {
            urls = [
              {
                template = "https://home-manager-options.extranix.com/";
                params = [
                  {
                    name = "release";
                    value = "master";
                  }
                  {
                    name = "query";
                    value = "{searchTerms}";
                  }
                ];
              }
            ];
            icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = ["@ho"];
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
            icon = "https://mynixos.com/favicon.ico";
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
            icon = "https://wikipedia.org/favicon.ico";
            definedAliases = ["@wik"];
          };
        };
        order = ["SearX" "ddg" "google" "Nix Packages" "MyNixOS" "Wikipedia"];
      };
    };
  };
}
