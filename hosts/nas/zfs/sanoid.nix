{...}: {
  services.sanoid = {
    enable = true;
    templates.data = {
      hourly = 24;
      daily = 30;
      monthly = 12;
      yearly = 1;
      autoprune = true;
      autosnap = true;
    };
    templates.backup = {
      hourly = 24;
      daily = 30;
      monthly = 12;
      yearly = 1;
      autoprune = true;
      autosnap = false;
    };
    datasets."storage" = {
      useTemplate = ["data"];
      recursive = true;
    };
    datasets."storage/syncoid" = {
      useTemplate = ["backup"];
      recursive = true;
    };
    datasets."docker" = {
      useTemplate = ["data"];
      recursive = true;
    };
    datasets."vms" = {
      useTemplate = ["data"];
      recursive = true;
    };
  };

}
