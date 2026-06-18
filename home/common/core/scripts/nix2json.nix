{pkgs}:
pkgs.writeShellScriptBin "nix2json" ''
  nix eval --impure --file $1 --json | ${pkgs.jq}/bin/jq
''
