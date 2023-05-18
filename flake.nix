{
  description = "getchoo's personal website";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs-stable.follows = "nixpkgs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    pre-commit-hooks,
    ...
  }: let
    systems = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];

    forAllSystems = nixpkgs.lib.genAttrs systems;
    nixpkgsFor = forAllSystems (system: import nixpkgs {inherit system;});

    packageFn = pkgs: {
      getchoo-website = pkgs.callPackage ./nix {inherit self;};
    };
  in {
    checks = forAllSystems (system: {
      pre-commit-check = pre-commit-hooks.lib.${system}.run {
        src = ./.;
        hooks = {
          alejandra.enable = true;
          eslint.enable = true;
          prettier.enable = true;
          editorconfig-checker.enable = true;
        };
      };
    });

    devShells = forAllSystems (system: let
      pkgs = nixpkgsFor.${system};
      inherit (pkgs) mkShell;
      cache = pkgs.fetchYarnDeps {
        yarnLock = ./yarn.lock;
        sha256 = "sha256-yhhuIfXjJhSfA8lweJ/0iD1qhnS3Th7P4zT+8iiWB/8=";
      };
    in {
      default = mkShell {
        inherit (self.checks.${system}.pre-commit-check) shellHook;
        packages = with pkgs;
        with nodePackages; [
          alejandra
          cache
          eslint
          just
          nodejs
          prettier
          yarn
        ];
      };
    });

    nixosModules.default = import ./nix/module.nix;

    packages = forAllSystems (s: let
      pkgs = nixpkgsFor.${s};
      p = packageFn pkgs;
    in {
      inherit (p) getchoo-website;
      default = p.getchoo-website;
    });

    overlays.default = _: packageFn;
  };
}
