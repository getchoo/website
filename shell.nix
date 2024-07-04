{
  pkgs ? import nixpkgs {
    inherit system;
    config = { };
    overlays = [ ];
  },
  nixpkgs ? <nixpkgs>,
  system ? builtins.currentSystem,
  formatter ? pkgs.nixfmt-rfc-style,
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
