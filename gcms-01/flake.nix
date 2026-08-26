{
  description = "gcms-01 NixOS flake (Minisforum MS-01 mini-workstation)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... } @ all: {
    nixosConfigurations.gcms-01 = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";

      # Expose ALL flake inputs (incl. `inputs`) to modules via specialArgs
      specialArgs = all;

      modules = [
        ./hosts/gcms-01/configuration.nix

        # Home Manager, activated by the NixOS system build
        home-manager.nixosModules.home-manager {
          home-manager.useGlobalPkgs = true;
          home-manager.users.user = import ./lib/home.nix;
        }
      ];
    };
  };
}
