{ pkgs, ... }:
let
  dprintPlugins = pkgs.callPackage ./dprintPlugins { };
in
{
  projectRootFile = ".git/config";

  programs = {
    dprint = {
      enable = true;

      settings = {
        useTabs = true;

        plugins = map toString [
          dprintPlugins.json
          dprintPlugins.markdown
          dprintPlugins.typescript
          dprintPlugins."g-plane/malva"
          dprintPlugins."g-plane/markup_fmt"
        ];

        includes = [ "**/*.{css,json,md,ts,tsx}" ];

        json = {
          deno = true;
        };

        markdown = { };

        typescript = {
          deno = true;
        };

        malva = { };
        markup = { };
      };
    };

    deadnix.enable = true;
    nixfmt.enable = true;
    statix.enable = true;
  };
}
