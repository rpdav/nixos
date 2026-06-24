# flake-parts
This repo uses `flake-parts`. Most of the `flake-parts` documentation went over my head, so it took me a long time to get my head around it. That documentation seems to be targeted at users with a much better grasp on functional programming than I have. So this is my attempt at a guide for ameteurs like myself.

## Advantages
* Self-documenting modules: It's immediately obvious what a module is at the top of a file.
* Feature-focused: If you have a feature that requires nixos and home-manager config plus exported packages, these can all be declared in a single file.
* Easy to refactor: Imports are done by module names, so there are no relative import paths to break.
* Easier to understand: flakes are essentially a wrapper around a nixos configuration. `flake-parts` makes that explicit by literally wrapping nixos modules with flake functions.

## Disadvantages
It's not always obvious where to go to find or edit `nixosModules.appName`. Your configs don't have to worry about where a module is stored, but you still have to because you don't edit modules - you edit files.

## Differences
`flake-parts` does not change the underlying functionality of flake-based nix but it does change how you structure your modules.

### flake.nix

`flake-parts` takes flake outputs (`outputs.nixosConfigurations`, `outputs.homeModules`) and turns them into regular options that are dispersed through your config (`flake.nixosModules`, `flake.homeModules`). This takes the most confusing part of flakes (the outputs) and turns them into something more familiar (options within configuration modules). That means that `flake.nix` becomes little more than a list of inputs and a simple function importing a bunch of `.nix` files. The task of actually enabling the features within those files is done by importing named modules rather than the files themselves.

### import-tree

[import-tree](https://github.com/denful/import-tree) provides a simple function that imports all `.nix` files within a specified directory. It's commonly used in  By default it ignores any files or directories that start with `_` so any template files not part of your actual config can be omitted. I use this module like this:
```nix
inputs.import-tree.filterNot                # Call the import-tree function with the exclude filter
(inputs.nixpkgs.lib.hasInfix "flake.nix")   # Exclude anything with `flake.nix` in the filename
./.                                         # Import everything else
```

### New options
#### `flake` options
Most traditional flake outputs are now declared under the `flake` attribute set, including `nixosConfigurations`, `nixosModules`, and `nixosModules`. For instance:

```nix
# flake.nix
{
  inputs = {...};
  outputs = inputs: {
    nixosConfigurations.someHost = inputs.nixpkgs.lib.nixosSystem { modules = [ ./myModule.nix ]; };
    nixosModules.someModule = {pkgs, ...}: {
      environment.systemPackages = [ pkgs.foo ];
    };
    homeConfigurations.someUser = inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = inputs.nixpkgs.legacyPackages.x86-64_linux;
      modules = [./home.nix];
    };
  };
}
```
becomes
```nix
# configuration.nix
{inputs, ...}: { # this is the flake-parts wrapper module
  flake.nixosConfigurations.someHost = inputs.nixpkgs.lib.nixosSystem { modules = [ ./myModule.nix ]; }; # this is a nixosConfiguration within the flake-parts wrapper
  flake.nixosModules.someModule = {pkgs, ...}: {
    environment.systemPackages = [ pkgs.foo ];
  };
  flake.homeConfigurations.someUser = inputs.home-manager.lib.homeManagerConfiguration {
    pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
    modules = [./home.nix];
  };
}
```

Just like regular nixos or home-manager options can be defined in multiple files and merged during evaluation (as long as they don't conflict), so also can `flake` options. So you can wrap both `configuration.nix` and `hardware-configuration.nix` in the same `flake.nixosModules.hostConfig` definition.

#### perSystem
Packages are handled differently from other outputs since they need to know what system to build it for. Here is how they are defined:

```nix
# packages.nix
{...}:{
  systems = ["x86_64-linux" "aarch64-linux"]; # This is the list of systems for which you will build packages.
  perSystem = {pkgs, ...}:{
    packages = {
      somePackage = pkgs.writeShellScriptBin "foo" "bar"; # This package will be built for the systems defined in `systems` above.
    };
  };
}
```

`systems` only needs to be defined once in the entire config, and it does not need to be defined in the same file as `perSystem`.

## Custom outputs

If you want to create custom flake outputs and you intend to only use them within one file, you can just create use them. But if you want to spread them among multiple files and have them merged, they need to be declared as an option first. This can be done by importing a module that declares them (e.g. `inputs.home-manager.flakeModules.home-manager` for the options `flake.homeConfigurations` and `flake.homeModules`) or declaring them manually. This is how I have defined a `serviceModules` output in `./features/nix.nx`:
```nix
# customOptions.nix
{inputs, lib, moduleLocation}: {
  options = {
    flake = inputs.flake-parts.lib.mkSubmoduleOptions {
      serviceModules = lib.mkOption {
        type = lib.types.lazyAttrsOf lib.types.deferredModule;
        default = {};
        apply = mapAttrs (
          k: v: {
            _class = "nixos"; #homeManager for modules to be consumed by home-manager
            _file = "${toString moduleLocation}#serviceModules.${k}";
            imports = [v];
          }
        );
        description = ''
          Self-hosted service modules.

          You may use this for self-hosted service configurations,
          whether using docker/podman or native nixos services.
        '';
      };
    };
  };
}
```

## Gotchas

### error: infinite recursion encountered

Several things could cause this, but it could be the handling of the `self` and `inputs` toplevel arguments. By default, `flake-parts` modules have access to the `inputs` and `self` arguments. Unless they are passed through `specialArgs`, the child `nixosModules` do **not** have access to these. Assuming you aren't passing them through `specialArgs`:

This will work:
```nix
{self, ...}:{ 
  flake.nixosModules.myModule = {config, ...}: {
    imports = [self.nixosModules.anotherModule];
    foo = config.bar;
  };
}
```
This will **not** work:
```nix
{...}:{ 
  flake.nixosModules.myModule = {config, self, ...}: { # nixosModules does not know what `self` is
    imports = [self.nixosModules.anotherModule];
    foo = config.bar;
  };
}
```

### error: The option `flake' does not exist

This probably comes from importing a file which contains a `flake-parts` module instead of the child modules contained within it.
This is correct:
```nix
{self, ...}:{ 
  flake.nixosModules.myModule = {config, ...}: {
    imports = [self.nixosModules.anotherModule]; # Import modules by name
    foo = config.bar;
  };
}
```
This is incorrect:
```nix
{self, ...}:{ 
  flake.nixosModules.myModule = {config, ...}: {
    imports = [./anotherModule.nix]; # This imports a flake-parts module, which the nixosModule doesn't know how to handle
    foo = config.bar;
  };
}
```

