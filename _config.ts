import lume from "lume/mod.ts";
import attributes from "lume/plugins/attributes.ts";
import base_path from "lume/plugins/base_path.ts";
import code_highlight from "lume/plugins/code_highlight.ts";
import date from "lume/plugins/date.ts";
import remark from "lume/plugins/remark.ts";
import postcss from "lume/plugins/postcss.ts";
import sass from "lume/plugins/sass.ts";
import sitemap from "lume/plugins/sitemap.ts";
import tailwindcss from "lume/plugins/tailwindcss.ts";
import tailwind_catppuccin from "npm:@catppuccin/tailwindcss@0.1.1";

const getGitRevision = async () => {
	const p = Deno.run({
		cmd: ["git", "rev-parse", "HEAD"],
		stdout: "piped",
	});
	const [status, output] = await Promise.all([p.status(), p.output()]);

	if (status.success) {
		return new TextDecoder().decode(output).trim().substring(0, 8);
	}

	return null;
};

const site = lume({
	src: "./src",
	location: new URL("https://getchoo.github.io"),
});

site.use(attributes())
	.use(base_path())
	.use(code_highlight())
	.use(date())
	.use(remark())
	.use(sitemap())
	.use(sass())
	.use(
		tailwindcss({
			options: {
				plugins: [
					tailwind_catppuccin({
						defaultFlavour: "mocha",
					}),
				],
			},
		})
	)
	.use(postcss())
	.data("gitRevision", await getGitRevision())
	.ignore(
		"README.md",
		"LICENSE",
		".gitignore",
		".gitattributes",
		"flake.nix",
		"flake.lock",
		".editorconfig",
		".prettierignore",
		".envrc"
	)
	.copy("favicon.ico")
	.copy("files")
	.copy("imgs")
	.copy("js");

export default site;
