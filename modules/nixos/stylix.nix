{ pkgs, ... }:

let
  wallpaper = "snowflake";
in {

  stylix.enable = true;

  stylix.image = ../../themes/rocket/wallpaper.png;

#  stylix.image = "../../themes"+("/"+wallpaper+"/")+"wallpaper.png";
  
}
