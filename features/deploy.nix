{
  inputs,
  self,
  ...
}: {
  flake.nixosModules.core = {pkgs, ...}: {environment.systemPackages = [pkgs.deploy-rs];};
  flake.deploy.nodes = {
    nas = {
      hostname = "10.10.1.17";
      profiles.system = {
        user = "root";
        path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.nas;
      };
    };
    vps = {
      hostname = "100.111.223.13";
      profiles.system = {
        user = "root";
        path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.vps;
      };
    };
  };
}
