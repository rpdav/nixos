{config, ...}: let
  inherit (config.serviceOpts) dockerDir;
in {
  services.ollama = {
    enable = true;
    loadModels = [
      "llama3.2:3b"
      "deepseek-coder:6.7b"
      "deepseek-r1:8b"
    ];
    acceleration = "cuda";
    host = "0.0.0.0";
    openFirewall = true;
    home = "${dockerDir}/ollama";
    user = "ollama";
  };

  # This isn't a container, but this module still does the job
  virtualisation.oci-containers.mounts."ollama" = {
    target = "${dockerDir}/ollama";
    mode = "0755";
    user = "ollama";
    group = "nogroup";
  };
}
