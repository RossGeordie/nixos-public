{
  description = "A generic NixOS 26.05 starter — Plasma 6, Home Manager, sensible defaults";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... } @ all: {
    nixosConfigurations.example = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";

      # Expose ALL flake inputs (incl. `inputs`) to modules via specialArgs,
      # so a module can do `specialArgs.inputs.nixpkgs.url` etc.
      specialArgs = all;

      modules = [
        ./hosts/example/configuration.nix

        # Home Manager, activated by the NixOS system build.
        home-manager.nixosModules.home-manager {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.user = import ./lib/home.nix;
        }
      ];
    };
  };
}
