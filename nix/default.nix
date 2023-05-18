{
  self,
  mkYarnPackage,
  writeShellScriptBin,
  ...
}: let
  gitRev = writeShellScriptBin "git" ''
    echo ${self.rev or "dirty"};
  '';
in
  mkYarnPackage rec {
    pname = "getchoo-website";

    src = builtins.path {
      path = ../.;
      name = "getchoo-website-source";
    };

    packageJSON = src + "/package.json";
    yarnLock = src + "/yarn.lock";

    nativeBuildInputs = [gitRev];

    buildPhase = ''
      export HOME="$(mktemp -d)"
      yarn --offline build
    '';
  }
