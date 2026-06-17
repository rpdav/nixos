{
  pkgs,
  inputs,
}:
# spawns alacritty terminal to connect to linode lish server
# using alacritty because kitty throws term error and kitten
# ssh doesn't work for lish
pkgs.writeShellScriptBin "lish" ''
  alacritty -e ssh -t ${inputs.nix-secrets.vps.linodeUser}@lish-us-southeast.linode.com vps.${inputs.nix-secrets.selfhosting.domain}
''
