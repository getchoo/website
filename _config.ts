import lume from "lume/mod.ts";
import attributes from "lume/plugins/attributes.ts";
import base_path from "lume/plugins/base_path.ts";
import code_highlight from "lume/plugins/code_highlight.ts";
import date from "lume/plugins/date.ts";
import minify_html from "lume/plugins/minify_html.ts";
import postcss from "lume/plugins/postcss.ts";
import sass from "lume/plugins/sass.ts";
import sitemap from "lume/plugins/sitemap.ts";
import tailwindcss from "lume/plugins/tailwindcss.ts";
import tailwind_catppuccin from "catppuccin";

const getGitRevision = async () => {
	const cmd = new Deno.Command("git", {
		args: [
			"rev-parse",
			"HEAD",
		],
	});
	const { success, stdout } = await cmd.output();

	const fromEnv = Deno.env.get("GIT_REV");

	if (success) {
		console.log("Using git revision from git");
		return new TextDecoder().decode(stdout).trim().substring(0, 8);
	} else if (fromEnv) {
		console.log("Using git revision from env");
		return fromEnv.substring(0, 8);
	} else {
		console.warn("Not able to find git revision! Leaving it blank");
		return null;
	}
};

const site = lume({
	src: "./src",
	location: new URL("https://mydadleft.me"),
});

site.remoteFile(
	"_includes/css/code.css",
	"https://unpkg.com/@catppuccin/highlightjs@0.1.4/css/catppuccin-mocha.css",
);

site.use(attributes())
	.use(base_path())
	.use(code_highlight())
	.use(date())
	.use(minify_html())
	.use(sitemap())
	.use(sass())
	.use(tailwindcss({
		options: {
			plugins: [
				tailwind_catppuccin({
					defaultFlavour: "mocha",
				}),
			],
		},
	}))
	.use(postcss());

site.copy("public", ".");
site.data("gitCommit", await getGitRevision());

export default site;
