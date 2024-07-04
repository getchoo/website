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
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      forAllSystems = fn: nixpkgs.lib.genAttrs systems (system: fn nixpkgs.legacyPackages.${system});
    in
    {
      checks = forAllSystems (
        pkgs:
        let
          flake-checks' = flake-checks.lib.mkChecks {
            root = ./.;
            inherit pkgs;
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

      devShells = forAllSystems (
        { pkgs, system, ... }:
        {
          default = import ./shell.nix {
            inherit pkgs system;
            formatter = self.formatter.${system};
          };
        }
      );

      formatter = forAllSystems (pkgs: pkgs.nixfmt-rfc-style);

      packages = forAllSystems (
        { pkgs, system, ... }:
        let
          pkgs' = import ./. { inherit pkgs system; };
        in
        pkgs' // { default = pkgs'.website; }
      );
    };
}
