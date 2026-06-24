# Custom options

Several custom options are defined in `modules.nixos.customOptions`. These are used to set several system-, user-, or service-related options in each system's or user's config files. This allows shared modules to be tailored to each system/user without rewriting the whole module. Here are a few use cases:
* Use a common `disko` config but vary the swap file size based on `systemOpts.swapSize` (or disable swap entirely with `systemOpts.swapEnable`)
* Use a common list of packages to load packages on all system, but exclude gui apps for headless systems based on `systemOpts.gui` being set to false.
* Use a common `stylix` config for system-wide theming, but each user can set their own `userOpts.theme`, `userOpts.cursor`, and `userOpts.font`.
