{pkgs, ...}: {
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [nvidia-vaapi-driver];
  };

  services.xserver.videoDrivers = ["nvidia"];
  hardware.nvidia = {
    open = true;
    modesetting.enable = true;
  };

  # hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.legacy_470; # pin driver package to an older version
}
