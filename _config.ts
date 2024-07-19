import lume from "lume/mod.ts";
import inline from "lume/plugins/inline.ts";
import metas from "lume/plugins/metas.ts";
import minify_html from "lume/plugins/minify_html.ts";
import robots from "lume/plugins/robots.ts";
import sitemap from "lume/plugins/sitemap.ts";

const site = lume({ src: "./src" });

site.use(inline())
	.use(metas())
	.use(minify_html())
	.use(robots())
	.use(sitemap());

site.copy("static", ".");

export default site;
