{
  description = "seth's website";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs =
    { self, nixpkgs }:
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
          pkgs = nixpkgsFor.${system};
        in
        {
          check-lint =
            pkgs.runCommand "check-lint"
              {
                nativeBuildInputs = [
                  pkgs.actionlint
                  pkgs.deadnix
                  pkgs.statix
                ];
              }
              ''
                echo "running actionlint..."
                actionlint ${self}/.github/workflows/*

                echo "running deadnix..."
                deadnix --fail ${self}

                echo "running statix..."
                statix check ${self}

                touch $out
              '';

          check-formatting =
            pkgs.runCommand "check-formatting" { nativeBuildInputs = [ pkgs.nixfmt-rfc-style ]; }
              ''
                echo "running nixfmt..."
                nixfmt --check ${self}

                touch $out
              '';
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
