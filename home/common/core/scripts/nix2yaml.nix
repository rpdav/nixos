{pkgs}:
pkgs.writeShellScriptBin "nix2yaml" ''
  nix eval --impure --file $1 --json | ${pkgs.yj}/bin/yj -jti
''
