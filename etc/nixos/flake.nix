{
  description = "LuisChDev's NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    dotfile-sync.url = "/home/chava/Documents/HaskellProjects/dotfile-sync";
    whitesur-kde.url = "/home/chava/Documents/NixProjects/whitesur-kde-theme";
    localpkgs.url = "/home/chava/Documents/NixProjects/nixpkgs";

    nur.url = "github:nix-community/NUR";
    LuisChDev.url = "/home/chava/Documents/NixProjects/nur-packages";
  };

  outputs = { self, nixpkgs, nur, LuisChDev, ... }@attrs: {
    nixosConfigurations.phalanx = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = attrs;
      modules = let
        nur-modules = import nur {
          nurpkgs = nixpkgs.legacyPackages.x86_64-linux;
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
        };
      in [
        ./configuration.nix
        nur.nixosModules.nur
        nur-modules.repos.LuisChDev.modules.nordvpn
        # {
        #   nixpkgs.overlays = [
        #     (self: super: {
        #       nordvpn = nur-modules.repos.LuisChDev.nordvpn;
        #     })
        #   ];
        # }
      ];
    };
  };
}
