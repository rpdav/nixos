{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    beszel
  ];

  networking.firewall = {
    allowedTCPPorts = [8090];
  };

  systemd.services.beszel-agent = {
    description = "Beszel Agent";
    after = ["network-online.target"];
    wants = ["network-online.target"];
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      Restart = "always";
      RestartSec = 5;
      Environment = [
        "PORT=45876" # port to run the ssh server on
        "KEY=\"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINS1C1EsOwt0sForUyx88AL5tw+zL78+JwjadiskjtDN\"" #pubkey of beszel-hub;
        #	"\"EXTRA_FILESYSTEMS=/mnt/docker,/mnt/storage,/mnt/vms\"" #TODO: this doesn't pull disk usage of child zfs filesystems. also not multi-host compatible
      ];
      ExecStart = "${pkgs.beszel}/bin/beszel-agent";
    };
  };
}
