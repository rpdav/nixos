{
  lib,
  config,
  ...
}: let
  inherit (lib) mkIf;
  stylixDisable = !config.stylix.targets.starship.enable;
in {
  programs.bash.bashrcExtra = ''
    eval $(starship init bash)
  '';

  programs.starship = {
    enable = true;
    settings = {
      "$schema" = "https://starship.rs/config-schema.json";
      # Only enable palette settings if stylix is disabled.
      # Defaults below are catppuccin mocha.
      palette = mkIf stylixDisable "base16_mocha";
      palettes.base16_mocha = mkIf stylixDisable {
        black = "#1e1e2e";
        white = "#cdd64f";
        red = "#f38ba8";
        orange = "#fab387";
        yellow = "#f9e2af";
        green = "#a6e3a1";
        blue = "#89b4fa";
        purple = "#cba6f7";
      };
      character = {
        disabled = false;
        error_symbol = "[✗](bold fg:red)";
        success_symbol = "[➜](bold fg:green)";
        vimcmd_replace_one_symbol = "[❮](bold fg:white)";
        vimcmd_replace_symbol = "[❮](bold fg:white)";
        vimcmd_symbol = "[❮](bold fg:green)";
        vimcmd_visual_symbol = "[❮](bold fg:yellow)";
      };
      cmd_duration = {
        disabled = false;
        format = " in $duration ";
        min_time_to_notify = 45000;
        show_milliseconds = true;
        show_notifications = true;
        style = "bg:white";
      };
      directory = {
        format = "[ $path ]($style)";
        style = "bg:orange fg:black";
        substitutions = {
          Documents = "󰈙 ";
          Downloads = " ";
          Music = "󰝚 ";
          Pictures = " ";
          nixos = "󰲋 ";
        };
        truncation_length = 3;
        truncation_symbol = "…/";
      };
      docker_context = {
        format = "[[ $symbol( $context) ](fg:black bg:blue)]($style)";
        style = "bg:blue";
        symbol = "";
      };
      format = builtins.concatStringsSep "" [
        "[](red)"
        "$os"
        "$username"
        "$hostname"
        "[](bg:orange fg:red)"
        "$directory"
        "[](bg:yellow fg:orange)"
        "$git_branch"
        "$git_status"
        "[](fg:yellow bg:green)"
        "$nix_shell"
        "$python"
        "[](fg:green bg:blue)"
        "$conda"
        "[](fg:blue bg:purple)"
        "$time"
        "[ ](fg:purple)"
        "$cmd_duration"
        "$line_break"
        "$character"
      ];
      git_branch = {
        format = "[[ $symbol $branch ](fg:black bg:yellow)]($style)";
        style = "bg:yellow";
        symbol = "";
      };
      git_status = {
        format = "[[($all_status$ahead_behind )](fg:black bg:yellow)]($style)";
        style = "bg:yellow";
      };
      hostname = {
        disabled = false;
        format = "[@[$hostname]($style) [$ssh_symbol](bold blue bg:red)]($style)";
        ssh_only = false;
        ssh_symbol = "🌐 ";
        style = "bg:red fg:black";
      };
      line_break = {disabled = false;};
      nix_shell = {
        format = "[$symbol$state( \\($name\\))]($style)";
        style = "bg:green fg:black";
        symbol = " ";
      };
      os = {
        disabled = false;
        format = "[[$symbol]($style) ]($style)";
        style = "bg:red fg:black";
        symbols = {
          Arch = "󰣇";
          Debian = "󰣚";
          Linux = "󰌽";
          Macos = "󰀵";
          Mint = "󰣭";
          NixOS = "";
          Ubuntu = "󰕈";
          Windows = "";
        };
      };
      python = {
        format = "[[ $symbol( $version)(\\(#$virtualenv\\)) ](fg:black bg:green)]($style)";
        style = "bg:green";
        symbol = "";
      };
      time = {
        disabled = false;
        format = "[[ 󱑍 $time ](fg:black bg:purple)]($style)";
        style = "bg:purple";
        time_format = "%R";
      };
      username = {
        format = "[ $user]($style)";
        show_always = true;
        style_root = "bg:red fg:black";
        style_user = "bg:red fg:black";
      };
    };
  };
}
