alias b := build
alias f := fmt
alias uf := update-flake

build:
    yarn run build

[macos]
[windows]
fmt:
    prettier --editorconfig -w .

[linux]
fmt:
    prettier --editorconfig -w . && alejandra .

update-flake:
    nix flake update
