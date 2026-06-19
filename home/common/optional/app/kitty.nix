{...}: {
  flake.homeModules.kitty = {...}: {
    programs.kitty = {
      enable = true;
      settings = {
        cursor_trail = 3;
      };
    };
  };
}
