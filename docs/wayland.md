# Wayland compositors

This repo contains configurations for both Niri and Hyprland. Both are highly customizable for window placement rules, color, opacity, animations, and shadows.

## Niri
Niri is a "scrollable tiling" window manager written in rust. Workspaces spawn vertically and new windows spawn and scroll infinitely to the right as they are created, without automatically resizing.

Pros:
1. Feels snappier to me than Hyprland
2. I prefer the scrolling layout
3. Built-in overview feature

Cons:
1. Less established than Hyprland.
2. If you want to configure it with nix, there is no native `home-manager` module; but there is a [third party flake](https://github.com/epireyn/niri-flake) or [wrapper-modules](https://github.com/BirdeeHub/nix-wrapper-modules).

## Hyprland
Hyprland is a dynamic tiling window manager written in C++. Workspaces spawn horizontally and new windows spawn within a screen and resize existing windows.

Pros:
1. Big community behind it.
2. Native support in `home-manager`.
3. It supports a number of alternate layouts, so you don't **have** to use Niri if that's what you want.

Cons:
1. Felt a bit slower than Niri

## Components

Niri and Hyprland are both simply Wayland compositors, which mean they do not come with most of the elements of a traditional desktop environment, such as a status bar or launcher. For Niri, I use Noctalia which is an all-in-one solution to this. For Hyprland I use a variety of different tools:

| Feature                 | Niri     | Hyprland        |
|-------------------------|----------|-----------------|
| bar                     | noctalia | waybar          |
| osd (volume/brightness) | noctalia | swayosd         |
| screen lock             | noctalia | hyprlock        |
| idle daemon             | noctalia | hypridle        |
| app launcher            | noctalia | fuzzel          |
| notifications           | noctalia | swaync          |
| logout menu             | noctalia | wlogout         |
| wifi applet             | noctalia | nm-applet       |
| bluetooth applet        | noctalia | blueman-applet  |
| polkit (sudo for gui)   | noctalia | hyprpolkitagent |
| clipboard history       | noctalia | cliphist        |

There's no reason you couldn't use Noctalia on Hyprland or vice versa; this is just how I built each out. If you're just starting out, I would recommend starting with Noctalia to get up and running, and then swap out components if you want. 

As of this writing, Noctalia is undergoing a major rewrite from v4 to v5. There will be no simple upgrade path, so I would recommend jumping to v5. To do so, you will need to get the package from the [Noctalia flake](https://github.com/noctalia-dev/noctalia). That flake also provides `home-manager` options.
