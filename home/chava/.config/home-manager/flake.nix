{
  description = "home-manager's flake";

  inputs = {
    system-flake.url = "path:../../../../etc/nixos";
    localpkgs.url = "/home/chava/Documents/NixProjects/nixpkgs";
    nixpkgs.follows = "system-flake/nixpkgs";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "system-flake/nixpkgs";
    };

    # experimental
    plasma-manager = {
      url = "github:pjones/plasma-manager";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
    };
  };

  outputs = { localpkgs, nixpkgs, home-manager, plasma-manager, ... }:
    let
      system = "x86_64-linux";
      # locpkgs = import localpkgs { inherit system; };
      pkgs = (import nixpkgs {
        inherit system;
        # overlays =
        #   [ (self: super: { hunspellDicts = locpkgs.hunspellDicts; }) ];
        config = {
          allowUnfree = true;
          permittedInsecurePackages = [ "nodejs-10.24.1" ];
        };
      });

    in {
      homeConfigurations.chava = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          plasma-manager.homeManagerModules.plasma-manager
          ./home.nix
        ];
      };
    };
}
