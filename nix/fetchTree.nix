# this code is slightly modified from https://github.com/edolstra/flake-compat
##
## Copyright (c) 2020-2021 Eelco Dolstra and the flake-compat contributors
##
## Permission is hereby granted, free of charge, to any person obtaining
## a copy of this software and associated documentation files (the
## "Software"), to deal in the Software without restriction, including
## without limitation the rights to use, copy, modify, merge, publish,
## distribute, sublicense, and/or sell copies of the Software, and to
## permit persons to whom the Software is furnished to do so, subject to
## the following conditions:
##
## The above copyright notice and this permission notice shall be
## included in all copies or substantial portions of the Software.
##
## THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
## EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
## MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
## NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
## LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
## OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
## WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
let
  formatSecondsSinceEpoch = t: let
    rem = x: y: x - x / y * y;
    days = t / 86400;
    secondsInDay = rem t 86400;
    hours = secondsInDay / 3600;
    minutes = (rem secondsInDay 3600) / 60;
    seconds = rem t 60;

    # Courtesy of https://stackoverflow.com/a/32158604.
    z = days + 719468;
    era =
      (
        if z >= 0
        then z
        else z - 146096
      )
      / 146097;
    doe = z - era * 146097;
    yoe = (doe - doe / 1460 + doe / 36524 - doe / 146096) / 365;
    y = yoe + era * 400;
    doy = doe - (365 * yoe + yoe / 4 - yoe / 100);
    mp = (5 * doy + 2) / 153;
    d = doy - (153 * mp + 2) / 5 + 1;
    m =
      mp
      + (
        if mp < 10
        then 3
        else -9
      );
    y' =
      y
      + (
        if m <= 2
        then 1
        else 0
      );

    pad = s:
      if builtins.stringLength s < 2
      then "0" + s
      else s;
  in "${toString y'}${pad (toString m)}${pad (toString d)}${pad (toString hours)}${pad (toString minutes)}${pad (toString seconds)}";

  fetchTree = info:
    if info.type == "github"
    then {
      outPath =
        fetchTarball
        (
          {url = "https://api.${info.host or "github.com"}/repos/${info.owner}/${info.repo}/tarball/${info.rev}";}
          // (
            if info ? narHash
            then {sha256 = info.narHash;}
            else {}
          )
        );
      inherit (info) rev lastModified narHash;
      shortRev = builtins.substring 0 7 info.rev;
      lastModifiedDate = formatSecondsSinceEpoch info.lastModified;
    }
    else if info.type == "git"
    then
      {
        outPath =
          builtins.fetchGit
          (
            {inherit (info) url;}
            // (
              if info ? rev
              then {inherit (info) rev;}
              else {}
            )
            // (
              if info ? ref
              then {inherit (info) ref;}
              else {}
            )
            // (
              if info ? submodules
              then {inherit (info) submodules;}
              else {}
            )
          );
        inherit (info) lastModified narHash;
        lastModifiedDate = formatSecondsSinceEpoch info.lastModified;
      }
      // (
        if info ? rev
        then {
          inherit (info) rev;
          shortRev = builtins.substring 0 7 info.rev;
        }
        else {
        }
      )
    else if info.type == "path"
    then {
      outPath = builtins.path {inherit (info) path;};
      inherit (info) narHash;
    }
    else if info.type == "tarball"
    then {
      outPath =
        fetchTarball
        (
          {inherit (info) url;}
          // (
            if info ? narHash
            then {sha256 = info.narHash;}
            else {}
          )
        );
    }
    else if info.type == "gitlab"
    then {
      inherit (info) rev narHash lastModified;
      outPath =
        fetchTarball
        (
          {url = "https://${info.host or "gitlab.com"}/api/v4/projects/${info.owner}%2F${info.repo}/repository/archive.tar.gz?sha=${info.rev}";}
          // (
            if info ? narHash
            then {sha256 = info.narHash;}
            else {}
          )
        );
      shortRev = builtins.substring 0 7 info.rev;
    }
    else if info.type == "sourcehut"
    then {
      inherit (info) rev narHash lastModified;
      outPath =
        fetchTarball
        (
          {url = "https://${info.host or "git.sr.ht"}/${info.owner}/${info.repo}/archive/${info.rev}.tar.gz";}
          // (
            if info ? narHash
            then {sha256 = info.narHash;}
            else {}
          )
        );
      shortRev = builtins.substring 0 7 info.rev;
    }
    else
      # FIXME: add Mercurial, tarball inputs.
      throw "flake input has unsupported input type '${info.type}'";
in
  fetchTree
