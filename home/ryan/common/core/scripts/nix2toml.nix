{pkgs}:
pkgs.writeShellScriptBin "nix2toml" ''
  nix eval --impure --file $1 --json | ${pkgs.yj}/bin/yj -jy
''
