{
  description = "home-manager's flake";

  inputs = {
    system-flake.url = "/etc/nixos";
    nixpkgs.follows = "system-flake/nixpkgs";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "system-flake/nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... }:
    let
      system = "x86_64-linux";
      pkgs = (import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
        };
      });

    in {
      homeConfigurations.chava = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [ ./home.nix ];
      };
    };
}
