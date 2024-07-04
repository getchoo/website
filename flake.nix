{
  description = "seth's website";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-checks.url = "github:getchoo/flake-checks";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-checks,
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
    in
    {
      checks = forAllSystems (
        system:
        let
          flake-checks' = flake-checks.lib.mkChecks {
            root = ./.;
            pkgs = nixpkgsFor.${system};
          };
        in
        {
          inherit (flake-checks')
            actionlint
            alejandra
            deadnix
            statix
            ;
        }
      );

      devShells = forAllSystems (system: {
        default = import ./shell.nix {
          inherit system;
          pkgs = nixpkgsFor.${system};
          formatter = self.formatter.${system};
        };
      });

      formatter = forAllSystems (system: nixpkgsFor.${system}.nixfmt-rfc-style);

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
