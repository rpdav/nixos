{lib, ...}: {
  services.nextcloud-client = {
    enable = true;
    startInBackground = true;
  };

  # client starts to early and fails; this delays it a bit
  systemd.user.services.nextcloud-client = {
    Unit = {
      After = lib.mkForce "graphical-session.target";
    };
  };
}
