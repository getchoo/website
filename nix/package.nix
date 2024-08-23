{
  lib,
  stdenvNoCC,
  writeShellApplication,
  miniserve,
  zola,

  nix-filter,
  self,
}:

let
  website = stdenvNoCC.mkDerivation {
    pname = "getchoo-website";
    version = builtins.substring 0 8 self.lastModifiedDate or "dirty";

    src = nix-filter.lib {
      root = self;
      include = [
        "config.toml"
        "content"
        "static"
        "templates"
      ];
    };

    nativeBuildInputs = [ zola ];

    dontConfigure = true;
    dontFixup = true;

    buildPhase = "zola build";
    installPhase = "mv public $out";

    passthru = {
      serve = writeShellApplication {
        name = "serve";
        runtimeInputs = [ miniserve ];

        text = ''
          miniserve ${website}/
        '';
      };
    };

    meta = {
      homepage = "https://github.com/getchoo/website";
      license = lib.licenses.mit;
      maintainers = with lib.maintainers; [ getchoo ];
    };
  };
in
website
