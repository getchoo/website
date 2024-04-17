{
  lib,
  runCommand,
  actionlint,
  biome,
  deadnix,
  formatter,
  eclint,
  statix,
  ...
}: {
  actionlint = runCommand "check-actionlint" {} ''
    ${lib.getExe actionlint} ${../.github/workflows}/*
    touch $out
  '';

  biome-fmt = runCommand "check-biome-fmt" {} ''
    ${lib.getExe biome} format ${../.}/**/*
    touch $out
  '';

  biome-lint = runCommand "check-biome-lint" {} ''
    ${lib.getExe biome} lint ${../.}/**/*
    touch $out
  '';

  deadnix = runCommand "check-deadnix" {} ''
    ${lib.getExe deadnix} ${../.}
    touch $out
  '';

  "${formatter.pname}" = runCommand "check-${formatter.pname}" {} ''
    ${lib.getExe formatter} --check ${../.}
    touch $out
  '';

  eclint = runCommand "check-eclint" {} ''
    ${lib.getExe eclint} ${../.}/**/*
    touch $out
  '';

  statix = runCommand "check-statix" {} ''
    ${lib.getExe statix} check ${../.}
    touch $out
  '';
}
