let
  lock = builtins.fromJSON (builtins.readFile ./flake.lock);
  fetchTree = import ./nix/fetchTree.nix;
  flakeSources = builtins.mapAttrs (_: node: fetchTree node.locked) lock.nodes;
in
  {
    nixpkgs ?
      import sources.nixpkgs {
        inherit system;
        config = {};
        overlays = [];
      },
    system ? builtins.currentSystem,
    sources ? flakeSources,
  }: let
    pkgs' = import ./overlay.nix (nixpkgs // pkgs') nixpkgs;
  in
    pkgs'
