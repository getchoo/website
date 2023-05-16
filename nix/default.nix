{mkYarnPackage, ...}:
mkYarnPackage rec {
  name = "getchoo-website";

  src = builtins.path {
    path = ../.;
    name = "getchoo-website-source";
  };

  packageJSON = src + "/package.json";
  yarnLock = src + "/yarn.lock";

  buildPhase = ''
    export HOME="$(mktemp -d)"
    yarn --offline build
  '';
}
