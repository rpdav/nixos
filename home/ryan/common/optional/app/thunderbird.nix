{...}: {
  programs.thunderbird = {
    enable = true;
    settings = {
      "privacy.donottrackheader.enabled" = true;
    };
    profiles.ryan = {
      isDefault = true;
    };
  };
}
