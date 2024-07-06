{ lib, newScope }:
lib.makeScope newScope (
  final:
  let
    plugins = import ./plugins.nix {
      inherit lib;
      inherit (final) callPackage;
    };
  in
  {
    mkPlugin = final.callPackage (
      { fetchurl }:
      {
        pname,
        version,
        hash,
      }:
      fetchurl {
        url = "https://plugins.dprint.dev/${pname}-${version}.wasm";
        inherit hash;
      }
    ) { };
  }
  // plugins
)
