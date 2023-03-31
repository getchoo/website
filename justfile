alias s := serve
alias d := deps
alias f := fmt

serve:
	deno task serve

deps:
	deno cache --config deno.json --lock deno.lock _config.ts

[macos]
[windows]
fmt:
	prettier --editorconfig -w .

[linux]
fmt:
	prettier --editorconfig -w . && alejandra .
