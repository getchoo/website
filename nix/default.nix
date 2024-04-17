{
  lib,
  stdenvNoCC,
  cacert,
  jq,
  moreutils,
  nodejs,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  name = "getchoo-website";

  src = lib.fileset.toSource {
    root = ../.;
    fileset = lib.fileset.gitTracked ../.;
  };

  __structuredAttrs = true;

  nativeBuildInputs = [
    nodejs
    nodejs.pkgs.pnpm
  ];

  env = {
    pnpmDeps = stdenvNoCC.mkDerivation (finalAttrs': {
      name = "${finalAttrs.name}-pnpm-deps";
      inherit (finalAttrs) src;

      __structuredAttrs = true;

      nativeBuildInputs = [
        cacert
        jq
        moreutils
        nodejs.pkgs.pnpm
      ];

      dontConfigure = true;
      dontBuild = true;
      doCheck = false;

      installPhase = ''
        runHook preInstall

        export HOME="$(mktemp -d)"
        pnpm config set store-dir "$out"
        pnpm install --force --frozen-lockfile --ignore-script

        runHook postInstall
      '';

      fixupPhase = ''
        runHook preFixup

        rm -rf "$out"/v3/tmp
        for f in $(find "$out" -name "*.json"); do
          sed -i -E -e 's/"checkedAt":[0-9]+,//g' $f
          jq --sort-keys . $f | sponge $f
        done

        runHook postFixup
      '';

      outputHashMode = "recursive";
      outputHash = "sha256-Rd5fdB/pMxHRwy6gRTjQQWX4OlKHUJIqh2KX+9jiBQY=";
    });
  };

  postConfigure = ''
    export HOME="$(mktemp -d)"
    export STORE_PATH="$(mktemp -d)"

    cp -rT "$pnpmDeps" "$STORE_PATH"
    chmod -R +w "$STORE_PATH"

    pnpm config set store-dir "$STORE_PATH"

    pnpm install --force --frozen-lockfile --ignore-script --offline

    patchShebangs node_modules/{*,.*}
  '';

  buildPhase = ''
    runHook preBuild
    pnpm run build
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mv dist "$out"
    runHook postInstall
  '';

  checkPhase = ''
    runHook preCheck
    pnpm run check
    runHook postCheck
  '';

  meta = with lib; {
    homepage = "https://github.com/getchoo/website";
    license = licenses.mit;
    maintainers = with maintainers; [getchoo];
  };
})
