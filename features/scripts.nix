# Miscellaneous small scripts exported as packages
{...}: {
  perSystem = {
    config,
    pkgs,
    ...
  }: let
    inherit (pkgs) writeShellScriptBin;
    compose-targets = "$(systemctl list-units --all --type=target | grep docker-compose | awk '{print $1}')";
  in {
    packages = {
      # Check filesystem differences.
      # Useful when figuring out which
      # to persist.
      fs-diff = pkgs.writeShellScriptBin "fs-diff" ''
        sudo ${pkgs.findutils}/bin/find $1 -mount ! -type l,d
      '';

      # from/to nix conversion tools
      json2nix = pkgs.writeShellScriptBin "json2nix" ''
        nix eval --impure --expr "builtins.fromJSON (builtins.readFile $1)"
      '';
      toml2nix = pkgs.writeShellScriptBin "toml2nix" ''
        nix eval --impure --expr "builtins.fromTOML (builtins.readFile $1)"
      '';
      yaml2nix = pkgs.writeShellScriptBin "yaml2nix" ''
        cat $1 | ${pkgs.yj}/bin/yj -i > ./temp.json
        json2nix ./temp.json
        rm temp.json
      '';
      nix2json = pkgs.writeShellScriptBin "nix2json" ''
        nix eval --impure --file $1 --json | ${pkgs.jq}/bin/jq
      '';
      nix2toml = pkgs.writeShellScriptBin "nix2toml" ''
        nix eval --impure --file $1 --json | ${pkgs.yj}/bin/yj -jy
      '';
      nix2yaml = pkgs.writeShellScriptBin "nix2yaml" ''
        nix eval --impure --file $1 --json | ${pkgs.yj}/bin/yj -jti
      '';

      # Docker container management tools
      dup = writeShellScriptBin "dup" "sudo systemctl restart docker-$1.service";
      ddown = writeShellScriptBin "ddown" "sudo systemctl stop docker-$1.service";
      dcup = writeShellScriptBin "dcup" "sudo systemctl restart docker-compose-$1-root.target";
      dcdown = writeShellScriptBin "dcdown" "sudo systemctl stop docker-compose-$1-root.target";
      dtail = writeShellScriptBin "dtail" "docker logs -tf -n 50 $1";
      dexec = writeShellScriptBin "dexec" "docker exec -it $1 /bin/bash";
      dclist = writeShellScriptBin "dclist" "systemctl list-units --all --type=target | grep -E 'UNIT|docker-compose-'";
      dcupall = writeShellScriptBin "dcupall" ''
        for i in ${compose-targets}; do sudo systemctl restart $i
        done
      '';
      dcdownall = writeShellScriptBin "dcdownall" ''
        for i in ${compose-targets}; do sudo systemctl stop $i
        done
      '';
    };
  };
}
