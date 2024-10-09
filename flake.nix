{
  description = "Getchoo's website";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs =
    {
      self,
      nixpkgs,
    }:
    let
      inherit (nixpkgs) lib;
      systems = lib.systems.flakeExposed;

      forAllSystems = lib.genAttrs systems;
      nixpkgsFor = forAllSystems (system: nixpkgs.legacyPackages.${system});
    in
    {
      devShells = forAllSystems (
        system:
        let
          pkgs = nixpkgsFor.${system};

          baseNodeTools = [
            pkgs.corepack
            pkgs.nodejs
            pkgs.nrr
          ];
        in
        {
          default = pkgs.mkShellNoCC {
            packages = baseNodeTools ++ [
              # Language servers
              pkgs.astro-language-server
              pkgs.typescript-language-server
              pkgs.vscode-langservers-extracted

              # For CI
              pkgs.actionlint

              # Nix tools
              pkgs.deadnix
              pkgs.nil
              pkgs.statix
              self.formatter.${system}
            ];
          };

          ci = pkgs.mkShellNoCC {
            packages = baseNodeTools;
          };
        }
      );

      formatter = forAllSystems (system: nixpkgsFor.${system}.nixfmt-rfc-style);
    };
}
