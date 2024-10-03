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
    version = self.shortRev or self.dirtyShortRev or "unknown";

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

    postBuild = "zola build";
    postInstall = "mv public $out";

    dontConfigure = true;
    dontFixup = true;

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
