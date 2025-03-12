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
  ci-shell = import ./ci-shell.nix { inherit pkgs; };
in

pkgs.mkShellNoCC {
  packages =
    lib.attrValues {
      inherit (pkgs)
        # Language servers
        astro-language-server
        typescript-language-server
        vscode-langservers-extracted

        # For CI
        actionlint

        # Nix tools
        deadnix
        statix
        ;
    }
    ++ ci-shell.nativeBuildInputs;
}
