## things to fix
* how to get swayidle working as intended
* make blueman-applet spawn floating and small
* several tools (swaync, udiskie) are generic and should come out of hyprland.nix
* palm rejection seems worse
* replace hard coded colors with stylix ones
* do I want to go with wrappers like vj or write a simple programs.niri HM module? Would be nice to convert from nix to kdl but that might not be feasible.
* gnome is allowing fprintd login when I think it shouldn't

## config options
will try niri-flake for HM options - do I want to stick with regular nixpkgs for niri or use this flake?

## overlapping tools
* hyprpaper vs swaybg (no stylix integration)
* hyprpolkit vs polkit-gnome
* hyprlock vs swaylock
* hypridle vs swayidle
* hyprshot vs built-in screenshots

Am I going to switch between them? If so, how to make sure the right one is in use?
Am I going to stick with one? If so, where should they live? In a generic wayland tools module?

## noctalia-shell
### Things noctalia can replace:
* bar
* osd
* lock
* idle
* launcher
* notifications
* logout
* wifi applet
* bluetooth applet
* calendar? can at least view, but maybe not add events
* polkit

### questions
what is a "toast" in notifications?

### Things to fix:
some systray icons are broken
battery widget not working
need a widget for tailscale accept-routes
icons in starship seem broken for new files but not old ones
lock screen isn't working with fprintd
