{
  inputs,
  self,
  ...
}: {
  flake.nixosModules.admin = {pkgs, ...}: {environment.systemPackages = [inputs.deploy-rs.packages.${pkgs.stdenv.hostPlatform.system}.deploy-rs];};
  flake.deploy.nodes = {
    nas = {
      hostname = "10.10.1.17";
      profiles.system = {
        user = "root";
        sshUser = "root";
        path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.nas;
      };
    };
    vps = {
      hostname = "100.111.223.13";
      profiles.system = {
        user = "root";
        sshUser = "root";
        path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.vps;
      };
    };
    retropi = {
      hostname = "10.10.1.10";
      profiles.system = {
        user = "root";
        sshUser = "root";
        path = inputs.deploy-rs.lib.aarch64-linux.activate.nixos self.nixosConfigurations.vps;
      };
    };
  };
}
