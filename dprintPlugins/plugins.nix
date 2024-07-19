{ lib, callPackage }:
lib.mapAttrs
  (pname: { version, hash }: callPackage ({ mkPlugin }: mkPlugin { inherit pname version hash; }) { })
  {
    # https://github.com/dprint/dprint-plugin-json
    json = {
      version = "0.19.3";
      hash = "sha256-6JtfO11zcS8bHKAXvOnN9n3jCn0NukeAeAng0mKwH7k=";
    };

    # https://github.com/dprint/dprint-plugin-markdown
    markdown = {
      version = "0.17.1";
      hash = "sha256-syZN4k0qelu5giuQtOcgVaZCiVLHXX8lQB9MKgFbvvM=";
    };

    # https://github.com/dprint/dprint-plugin-typescript
    typescript = {
      version = "0.91.2";
      hash = "sha256-Zz9R/nkyFhBbF+2CE6Ok5v+2CX7uBge1KNUJhBsO0Hg=";
    };

    # https://github.com/g-plane/malva
    "g-plane/malva" = {
      version = "v0.5.1";
      hash = "sha256-3Cwn5WQMD318ZbjhoXqg59AqRNdkd0oG8BGFtFkCPcI=";
    };

    # https://github.com/g-plane/markup_fmt
    "g-plane/markup_fmt" = {
      version = "v0.10.0";
      hash = "sha256-NBtKMyf+ObZ0YbZJHfiWly6icwW6K+PUwtnWO6bWjNs=";
    };
  }
