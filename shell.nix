let
  lock = builtins.fromJSON (builtins.readFile ./flake.lock);
  fetchTree = import ./nix/fetchTree.nix;
  flakeSources = builtins.mapAttrs (_: node: fetchTree node.locked) lock.nodes;
in
  {
    pkgs ?
      import sources.nixpkgs {
        inherit system;
        config = {};
        overlays = [];
      },
    system ? builtins.currentSystem,
    sources ? flakeSources,
    formatter ? pkgs.alejandra,
  }:
    pkgs.mkShellNoCC {
      packages = [
        pkgs.zola

        # linters + formatters
        formatter
        pkgs.actionlint
        pkgs.nodePackages.alex
        pkgs.nodePackages.prettier
      ];
    }
