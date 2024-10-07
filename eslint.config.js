import eslint from "@eslint/js";
import teslint from "typescript-eslint";
import astro from "eslint-plugin-astro";
import prettier from "eslint-config-prettier";

export default teslint.config(
	eslint.configs.recommended,
	...teslint.configs.strict,
	...teslint.configs.stylistic,
	...astro.configs.recommended,
	...astro.configs["jsx-a11y-strict"],
	prettier,
	{
		ignores: ["src/env.d.ts"]
	}
);
