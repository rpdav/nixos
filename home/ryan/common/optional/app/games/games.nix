{
  config,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    moonlight-qt
    (retroarch.override {
      cores = with libretro; [
        snes9x
        vba-m
        melonds
      ];
    })
  ];
}
