{
  description = "LuisChDev's NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    dotfile-sync.url = "/home/chava/Documents/HaskellProjects/dotfile-sync";
    whitesur-kde.url = "/home/chava/Documents/NixProjects/whitesur-kde-theme";
    localpkgs.url = "/home/chava/Documents/NixProjects/nixpkgs";
  };

  outputs = { self, nixpkgs, ... }@attrs: {
    nixosConfigurations.phalanx = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = attrs;
      modules = [ ./configuration.nix ];
    };
  };
}
