{
  pkgs ? import <nixpkgs> {
    inherit system;
    config = { };
    overlays = [ ];
  },
  system ? builtins.currentSystem,
}:

let
  inherit (pkgs) lib;
in

pkgs.mkShellNoCC {
  packages = lib.attrValues {
    inherit (pkgs) corepack nodejs nrr;
  };
}
