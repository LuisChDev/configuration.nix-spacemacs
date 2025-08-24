{
  description = "LuisChDev's NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # dotfile-sync.url = "/home/chava/Documents/HaskellProjects/dotfile-sync";
    # whitesur-kde.url = "/home/chava/Documents/NixProjects/whitesur-kde-theme";
    whitesur-kde = {
      url = "/home/chava/Documents/NixProjects/whitesur-kde-theme";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # localpkgs.url = "/home/chava/Documents/NixProjects/nixpkgs";
    # nordvpn = {
    #   url = "/home/chava/Documents/NixProjects/nordvpn";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    # nur = {
    #   url = "github:nix-community/NUR";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    # LuisChDev.url = "/home/chava/Documents/NixProjects/nur-packages";
  };

  outputs = { self, nixpkgs, ... }@attrs: {
    nixosConfigurations.phalanx = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = attrs;
      modules = [
        ./configuration.nix
        # nur.modules.nixos.default
        # nur.legacyPackages.x86_64-linux.repos.LuisChDev.modules.nordvpn
        # nur-modules.repos.LuisChDev.modules.nordvpn
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
