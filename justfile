alias b := build
alias d := dev
alias f := fmt
alias p := preview
alias u := update
alias uf := update-flake

build:
    pnpm run build

dev:
    pnpm run dev

fmt:
    prettier --editorconfig -w .

preview: build
    pnpm run preview

update:
    pnpm update

update-flake:
    nix flake update
