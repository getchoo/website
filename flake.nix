{
  description = "seth's website";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs = {
    self,
    nixpkgs,
  }: let
    systems = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];

    forAllSystems = fn: nixpkgs.lib.genAttrs systems (system: fn nixpkgs.legacyPackages.${system});
  in {
    checks = forAllSystems (
      {
        pkgs,
        system,
        ...
      }:
        import ./nix/checks.nix (pkgs // {formatter = self.formatter.${system};})
    );

    devShells = forAllSystems ({
      pkgs,
      system,
      ...
    }: {
      default = import ./shell.nix {
        inherit system;
        nixpkgs = pkgs;
        formatter = self.formatter.${system};
      };
    });

    formatter = forAllSystems (pkgs: pkgs.alejandra);

    packages = forAllSystems ({
      pkgs,
      system,
      ...
    }: let
      pkgs' = import ./. {
        inherit system;
        nixpkgs = pkgs;
      };
    in
      pkgs' // {default = pkgs'.website;});

    overlays.default = final: prev: import ./overlay.nix final prev;
  };
}
