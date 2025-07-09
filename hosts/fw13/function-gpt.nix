{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  # Function to generate environment.etc entries
  generateTextFiles = files:
    mapAttrs' (name: cfg: {
      name = "myfiles/${name}";
      value.source = pkgs.writeText "myfile-${name}" cfg.text;
    })
    files;
in {
  options.my.textFiles = mkOption {
    type = types.attrsOf (types.submodule {
      options.text = mkOption {
        type = types.str;
        description = "The text content of the file.";
      };
    });
    default = {};
    description = "A set of named text files to be written to /etc/myfiles/";
  };

  config = {
    environment.etc = mkMerge [
      (generateTextFiles config.my.textFiles)
    ];
  };
}
