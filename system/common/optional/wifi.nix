{
  inputs,
  config,
  ...
}: {
  # Populates wifi network(s) declaratively
  # Other wifi networks can be added imperatively to /etc/NetworkManager/system-connections

  sops.secrets.wifi_env = {
    sopsFile = "${inputs.nix-secrets.outPath}/common.yaml";
    restartUnits = ["network-online.target"];
  };

  # not compatible with network manager
  #networking.wireless.secretsFile = config.sops.secrets.wifi.path;
  #networking.wireless.networks = {
  #  skynet.pskRaw = "ext:skynet";
  #};

  networking.networkmanager = {
    enable = true;
    ensureProfiles.environmentFiles = [config.sops.secrets.wifi_env.path];
    ensureProfiles.profiles = {
      skynet = {
        connection = {
          id = "skynet";
          type = "wifi";
          interface-name = config.systemOpts.wifiInterface;
        };
        wifi = {
          ssid = "$WIFI_SSID";
          mode = "infrastructure";
        };
        wifi-security = {
          key-mgmt = "wpa-psk";
          psk = "$WIFI_PSK";
        };
        ipv4.method = "auto";
      };
    };
  };
}
