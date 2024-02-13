{
  description = "seth's website";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    pre-commit = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        nixpkgs-stable.follows = "nixpkgs";
        flake-compat.follows = "";
      };
    };
  };

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      imports = with inputs; [ treefmt-nix.flakeModule pre-commit.flakeModule ];

      systems =
        [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];

      perSystem = { lib, pkgs, config, self', ... }:
        let
          nodejs-slim = pkgs.nodejs-slim_20; # this should be the current lts

          enableAll = lib.flip lib.genAttrs (lib.const { enable = true; });
        in {
          treefmt = {
            projectRootFile = ".git/config";

            programs = enableAll [ "deadnix" "nixfmt" "prettier" ];

            settings.global = {
              excludes = [
                "./node_modules/*"
                "./dist/*"
                "./.astro/*"
                "flake.lock"
                "pnpm-lock.yaml"
              ];
            };
          };

          pre-commit.settings = {
            settings.treefmt.package = config.treefmt.build.wrapper;

            hooks = enableAll [
              "actionlint"
              "eclint"
              "eslint"
              "markdownlint"
              "nil"
              "statix"
              "treefmt"
            ];
          };

          devShells.default = pkgs.mkShellNoCC {
            shellHook = config.pre-commit.installationScript;
            packages = [
              self'.formatter
              nodejs-slim
              # use pnpm from package.json
              (pkgs.runCommand "corepack-enable" {
                nativeBuildInputs = [ nodejs-slim ];
              } ''
                mkdir -p $out/bin
                corepack enable --install-directory $out/bin
              '')
            ];
          };
        };
    };
}
