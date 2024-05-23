{
  lib,
  stdenvNoCC,
  writeShellApplication,
  zola,
}:
stdenvNoCC.mkDerivation {
  name = "getchoo-website";

  src = lib.fileset.toSource {
    root = ../.;
    fileset = lib.fileset.unions [
      ../config.toml
      ../content
      ../highlight_themes
      ../static
      ../templates
    ];
  };

  nativeBuildInputs = [
    zola
  ];

  dontConfigure = true;
  doCheck = false;

  buildPhase = ''
    runHook preBuild
    zola build
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mv public $out
    runHook postInstall
  '';

  passthru = {
    serve = writeShellApplication {
      name = "serve";
      runtimeInputs = [zola];

      text = ''
        zola serve
      '';
    };
  };

  meta = {
    homepage = "https://github.com/getchoo/website";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [getchoo];
  };
}
