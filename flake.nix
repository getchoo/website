{
  description = "seth's website";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      treefmt-nix,
    }:
    let
      inherit (nixpkgs) lib;
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      forAllSystems = lib.genAttrs systems;
      nixpkgsFor = forAllSystems (system: nixpkgs.legacyPackages.${system});
      treefmtFor = forAllSystems (system: treefmt-nix.lib.evalModule nixpkgsFor.${system} ./treefmt.nix);
    in
    {
      checks = forAllSystems (system: {
        treefmt = treefmtFor.${system}.config.build.check self;
      });

      devShells = forAllSystems (system: {
        default = import ./shell.nix {
          inherit system;
          pkgs = nixpkgsFor.${system};
          formatter = self.formatter.${system};
        };
      });

      formatter = forAllSystems (system: treefmtFor.${system}.config.build.wrapper);

      packages = forAllSystems (
        system:
        let
          pkgs' = import ./. {
            inherit system;
            pkgs = nixpkgsFor.${system};
          };
        in
        pkgs' // { default = pkgs'.website; }
      );
    };
}
