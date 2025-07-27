# Adapted from TLATER's config at https://github.com/TLATER/dotfiles/blob/master/home-modules/firefox-webapp.nix
{
  inputs,
  config,
  lib,
  ...
}: let
  inherit (builtins) getAttr stringLength substring;
  inherit (lib) mkOption mkEnableOption;
  inherit
    (lib.attrsets)
    mapAttrs
    mapAttrs'
    nameValuePair
    filterAttrs
    ;
  inherit (lib.strings) concatStringsSep toUpper;

  make-app-profiles = cfg:
    mapAttrs' (
      name: cfg:
        nameValuePair "home-manager-webapp-${name}" {
          inherit (cfg) extensions id;
          # userChrome settings taken from https://github.com/MrOtherGuy/firefox-csshacks/blob/master/chrome/autohide_toolbox.css
          userChrome = ''
            :root{
              --uc-autohide-toolbox-delay: 200ms; /* Wait 0.1s before hiding toolbars */
              --uc-toolbox-rotation: 82deg;  /* This may need to be lower on mac - like 75 or so */
            }

            :root[sizemode="maximized"]{
              --uc-toolbox-rotation: 88.5deg;
            }

            @media  (-moz-platform: windows){
              :root:not([lwtheme]) #navigator-toolbox{ background-color: -moz-dialog !important; }
            }

            :root[sizemode="fullscreen"],
            :root[sizemode="fullscreen"] #navigator-toolbox{ margin-top: 0 !important; }

            #navigator-toolbox{
              --browser-area-z-index-toolbox: 3;
              position: fixed !important;
              background-color: var(--lwt-accent-color,black) !important;
              transition: transform 82ms linear, opacity 82ms linear !important;
              transition-delay: var(--uc-autohide-toolbox-delay) !important;
              transform-origin: top;
              transform: rotateX(var(--uc-toolbox-rotation));
              opacity: 0;
              line-height: 0;
              z-index: 1;
              pointer-events: none;
              width: 100vw;
            }
            :root[sessionrestored] #urlbar[popover]{
              pointer-events: none;
              opacity: 0;
              transition: transform 82ms linear var(--uc-autohide-toolbox-delay), opacity 0ms calc(var(--uc-autohide-toolbox-delay) + 82ms);
              transform-origin: 0px calc(0px - var(--tab-min-height) - var(--tab-block-margin) * 2);
              transform: rotateX(89.9deg);
            }
            #mainPopupSet:has(> [panelopen]:not(#ask-chat-shortcuts,#selection-shortcut-action-panel,#chat-shortcuts-options-panel,#tab-preview-panel)) ~ toolbox #urlbar[popover],
            #navigator-toolbox:is(:hover,:focus-within,[movingtab]) #urlbar[popover],
            #urlbar-container > #urlbar[popover]:is([focused],[open]){
              pointer-events: auto;
              opacity: 1;
              transition-delay: 33ms;
              transform: rotateX(0deg);
            }
            #mainPopupSet:has(> [panelopen]:not(#ask-chat-shortcuts,#selection-shortcut-action-panel,#chat-shortcuts-options-panel,#tab-preview-panel)) ~ toolbox,
            #navigator-toolbox:has(#urlbar:is([open],[focus-within])),
            #navigator-toolbox:is(:hover,:focus-within,[movingtab]){
              transition-delay: 33ms !important;
              transform: rotateX(0);
              opacity: 1;
            }
            /* This makes things like OS menubar/taskbar show the toolbox when hovered in maximized windows.
             * Unfortunately it also means that other OS native surfaces (such as context menu on macos)
             * and other always-on-top applications will trigger toolbox to show up. */
            @media (-moz-bool-pref: "userchrome.autohide-toolbox.unhide-by-native-ui.enabled"),
                   -moz-pref("userchrome.autohide-toolbox.unhide-by-native-ui.enabled"){
              :root[sizemode="maximized"]:not(:hover){
                #navigator-toolbox:not(:-moz-window-inactive),
                #urlbar[popover]:not(:-moz-window-inactive){
                  transition-delay: 33ms !important;
                  transform: rotateX(0);
                  opacity: 1;
                }
              }
            }

            #navigator-toolbox > *{ line-height: normal; pointer-events: auto }

            /* Don't apply transform before window has been fully created */
            :root:not([sessionrestored]) #navigator-toolbox{ transform:none !important }

            :root[customizing] #navigator-toolbox{
              position: relative !important;
              transform: none !important;
              opacity: 1 !important;
            }

            #navigator-toolbox[inFullscreen] > #PersonalToolbar,
            #PersonalToolbar[collapsed="true"]{ display: none }

            /* This is a bit hacky fix for an issue that will make urlbar zero pixels tall after you enter customize mode */
            #urlbar[breakout][breakout-extend] > .urlbar-input-container{
              padding-block: calc(min(4px,(var(--urlbar-container-height) - var(--urlbar-height)) / 2) + var(--urlbar-container-padding)) !important;
            }
          '';

          settings =
            cfg.extraSettings
            // {
              "browser.sessionstore.resume_session_once" = false;
              "browser.sessionstore.resume_from_crash" = false;
              "browser.cache.disk.enable" = false;
              "browser.cache.disk.capacity" = 0;
              "browser.cache.disk.filesystem_reported" = 1;
              "browser.cache.disk.smart_size.enabled" = false;
              "browser.cache.disk.smart_size.first_run" = false;
              "browser.cache.disk.smart_size.use_old_max" = false;
              "browser.ctrlTab.previews" = true;
              "browser.tabs.warnOnClose" = false;
              "plugin.state.flash" = 2;
              "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
              "browser.tabs.drawInTitlebar" = false;
              "browser.tabs.inTitlebar" = 0;
              "browser.contentblocking.category" = "strict";
              "network.cookie.lifetimePolicy" = 0;
              "layout.css.prefers-color-scheme.content-override" = getAttr cfg.theme {
                dark = 0;
                light = 1;
                system = 2;
              };
            };
        }
    )
    cfg;
in {
  options.programs.firefox.webapps = mkOption {
    default = {};

    type = with lib.types;
      attrsOf (
        submodule {
          options = {
            enable = mkEnableOption "webapp";

            ####################
            # Firefox settings #
            ####################
            url = mkOption {
              type = str;
              description = "The URL of the webapp to launch.";
            };

            id = mkOption {
              type = int;
              description = "The Firefox profile ID to set.";
            };

            extraArgs = mkOption {
              type = listOf str;
              default = [];
              description = "Extra args to launch Firefox with.";
            };

            extraSettings = mkOption {
              type = attrsOf (either bool (either int str));
              default = {};
              description = "Additional Firefox profile settings.";
            };

            extensions.packages = mkOption {
              type = listOf package;
              default = [];
              description = "Additional Firefox profile extensions.";
            };

            backgroundColor = mkOption {
              type = str;
              default = "rgba(0, 0, 0, 0)";
              description = "The background color to use for loading pages.";
            };

            theme = mkOption {
              type = enum [
                "dark"
                "light"
                "system"
              ];
              default = "system";
              description = "The application CSS theme to use, if supported.";
            };

            #########################
            # Desktop file settings #
            #########################

            # Copied from xdg.desktopEntries, with slight modification for default settings
            name = mkOption {
              type = nullOr str;
              default = null;
              description = "Specific name of the application. Defaults to the capitalized attribute name.";
            };

            mimeType = mkOption {
              description = "The MIME type(s) supported by this application.";
              type = nullOr (listOf str);
              default = [
                "text/html"
                "text/xml"
                "application/xhtml_xml"
              ];
            };

            # Copied verbatim from xdg.desktopEntries.
            genericName = mkOption {
              type = nullOr str;
              default = null;
              description = "Generic name of the application.";
            };

            comment = mkOption {
              type = nullOr str;
              default = null;
              description = "Tooltip for the entry.";
            };

            categories = mkOption {
              type = nullOr (listOf str);
              default = null;
              description = "Categories in which the entry should be shown in a menu.";
            };

            icon = mkOption {
              type = nullOr (either path str);
              default = "./icon.png";
              description = "Icon to display in file manager, menus, etc.";
            };

            prefersNonDefaultGPU = mkOption {
              type = nullOr bool;
              default = null;
              description = ''
                If true, the application prefers to be run on a more
                powerful discrete GPU if available.
              '';
            };
          };
        }
      );

    description = "Websites to create special site-specific Firefox instances for.";
  };

  config = {
    programs.firefox.profiles = make-app-profiles config.programs.firefox.webapps;

    xdg.desktopEntries = mapAttrs (name: cfg: {
      inherit
        (cfg)
        genericName
        comment
        categories
        icon
        mimeType
        prefersNonDefaultGPU
        ;

      name =
        if cfg.name == null
        then (toUpper (substring 0 1 name)) + (substring 1 (stringLength name) name)
        else cfg.name;

      startupNotify = true;
      terminal = false;
      type = "Application";

      exec = concatStringsSep " " (
        [
          "${config.programs.firefox.package}/bin/firefox"
          "--class"
          "WebApp-${name}"
          "-P"
          "${config.programs.firefox.profiles."home-manager-webapp-${name}".path}"
          "--no-remote"
        ]
        ++ cfg.extraArgs
        ++ ["${cfg.url}"]
      );

      settings = {
        X-MultipleArgs = "false"; # Consider enabling, don't know what this does
        StartupWMClass = "WebApp-${name}";
      };
    }) (filterAttrs (_: webapp: webapp.enable) config.programs.firefox.webapps);
  };
}
