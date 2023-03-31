{
  description = "getchoo's personal website";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-22.11";
    nixpkgsUnstable.url = "nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs-stable.follows = "nixpkgs";
      inputs.nixpkgs.follows = "nixpkgsUnstable";
      inputs.flake-utils.follows = "flake-utils";
    };
  };

  outputs = {
    self,
    nixpkgsUnstable,
    flake-utils,
    pre-commit-hooks,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgsUnstable {inherit system;};
    in {
      checks = {
        pre-commit-check = pre-commit-hooks.lib.${system}.run {
          src = ./.;
          hooks = {
            alejandra.enable = true;
            prettier.enable = true;
            editorconfig-checker.enable = true;
          };
        };
      };

      devShells = let
        inherit (pkgs) mkShell;
        inherit (self.checks.${system}.pre-commit-check) shellHook;
      in {
        default = mkShell {
          inherit shellHook;
          packages = with pkgs; [
            alejandra
            deno
            fzf
            just
            nodePackages.prettier
          ];
        };
      };
    });
}
