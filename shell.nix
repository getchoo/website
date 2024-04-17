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
    formatter ? nixpkgs.alejandra,
  }:
    nixpkgs.mkShellNoCC {
      packages = [
        formatter
        nixpkgs.biome
        nixpkgs.nodejs-slim
        # use package manager from package.json
        nixpkgs.corepack
      ];
    }
