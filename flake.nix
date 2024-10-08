{
  description = "Getchoo's website";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-filter.url = "github:numtide/nix-filter";
  };

  outputs =
    {
      self,
      nixpkgs,
      nix-filter,
    }:
    let
      inherit (nixpkgs) lib;
      systems = lib.systems.flakeExposed;

      forAllSystems = lib.genAttrs systems;
      nixpkgsFor = forAllSystems (system: nixpkgs.legacyPackages.${system});
    in
    {
      apps = forAllSystems (
        system:
        let
          pkgs = nixpkgsFor.${system};
        in
        {
          serve = {
            type = "app";
            program = toString (
              pkgs.runCommand "serve-website" { nativeBuildInputs = [ pkgs.zola ]; } ''
                tmpdir=$(mktemp -d)
                cd ${self.packages.${system}.website.src}
                zola serve --force --output-dir "$tmpdir"
              ''
            );
          };
        }
      );

      devShells = forAllSystems (
        system:
        let
          pkgs = nixpkgsFor.${system};
        in
        {
          default = pkgs.mkShellNoCC {
            packages = [
              pkgs.zola

              pkgs.actionlint
              pkgs.deadnix
              pkgs.nil
              pkgs.statix
              self.formatter.${system}
            ];
          };
        }
      );

      formatter = forAllSystems (system: nixpkgsFor.${system}.nixfmt-rfc-style);

      packages = forAllSystems (
        system:
        let
          pkgs = nixpkgsFor.${system};
        in
        {
          website = pkgs.callPackage (
            {
              lib,
              stdenvNoCC,
              writeShellApplication,
              zola,
            }:

            stdenvNoCC.mkDerivation {
              pname = "getchoo-website";
              version = self.shortRev or self.dirtyShortRev or "unknown";

              src = nix-filter.lib.filter {
                root = self;
                include = [
                  "config.toml"
                  "content"
                  "highlight_themes"
                  "sass"
                  "static"
                  "templates"
                ];
              };

              nativeBuildInputs = [ zola ];

              postBuild = "zola build --output-dir $out";

              dontConfigure = true;
              dontInstall = true;
              dontFixup = true;

              meta = {
                homepage = "https://github.com/getchoo/website";
                license = lib.licenses.mit;
                maintainers = with lib.maintainers; [ getchoo ];
              };
            }
          ) { };

          default = self.packages.${system}.website;
        }
      );
    };
}
