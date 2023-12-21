{
  description = "getchoo's website";

  inputs = {
    nixpkgs.url = "nixpkgs/nixpkgs-unstable";
    nix-deno = {
      url = "github:nekowinston/nix-deno";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    nixpkgs,
    nix-deno,
    self,
    ...
  }: let
    systems = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];

    forSystem = system: fn:
      fn rec {
        pkgs = import nixpkgs {
          inherit system;
          overlays = [nix-deno.overlays.default];
        };

        inherit (pkgs) lib;
        self' = lib.mapAttrs (_: v: v.${system} or {}) self;
      };

    forAllSystems = fn: nixpkgs.lib.genAttrs systems (system: forSystem system fn);
  in {
    checks = forAllSystems ({
      lib,
      pkgs,
      self',
      ...
    }: {
      check-nil =
        pkgs.runCommand "check-nil" {
          nativeBuildInputs = with pkgs; [fd nil];
        } ''
          cd ${./.}
          fd . -e "nix" | while read -r file; do
            nil diagnostics "$file" || exit 1
          done

          touch $out
        '';

      "check-${self'.formatter.pname}" = pkgs.runCommand "check-${self'.formatter.pname}" {} ''
        ${lib.getExe self'.formatter} --check ${./.}

        touch $out
      '';

      check-statix =
        pkgs.runCommand "check-statix" {
          nativeBuildInputs = [pkgs.statix];
        } ''
          statix check ${./.}

          touch $out
        '';

      check-actionlint =
        pkgs.runCommand "check-actionlint" {
          nativeBuildInputs = [pkgs.actionlint];
        } ''
          actionlint ${./.github/workflows}/**

          touch $out
        '';

      check-denofmt =
        pkgs.runCommand "check-denofmt" {
          nativeBuildInputs = [pkgs.deno];
        } ''
          cd ${./.}
          export DENO_DIR="$(mktemp -d)"
          deno fmt --check

          touch $out
        '';

      check-denolint =
        pkgs.runCommand "check-denolint" {
          nativeBuildInputs = [pkgs.deno];
        } ''
          cd ${./.}
          export DENO_DIR="$(mktemp -d)"
          deno lint

          touch $out
        '';
    });

    devShells = forAllSystems ({
      pkgs,
      self',
      ...
    }: {
      default = pkgs.mkShell {
        packages = with pkgs; [
          deno
          actionlint

          self'.formatter
          nil
          statix
        ];
      };
    });

    formatter = forAllSystems ({pkgs, ...}: pkgs.alejandra);

    packages = forAllSystems ({
      lib,
      pkgs,
      self',
      ...
    }: {
      website = pkgs.denoPlatform.mkDenoDerivation {
        name = "website";
        stdenv = pkgs.stdenvNoCC;

        src = lib.cleanSource ./.;

        buildPhase = ''
          runHook preBuild

          deno task build

          runHook postBuild
        '';

        installPhase = ''
          cp -r _site $out
        '';
      };

      default = self'.packages.website;
    });
  };
}
