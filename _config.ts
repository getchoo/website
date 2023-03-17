import lume from "lume/mod.ts";
import attributes from "lume/plugins/attributes.ts";
import base_path from "lume/plugins/base_path.ts";
import code_highlight from "lume/plugins/code_highlight.ts";
import date from "lume/plugins/date.ts";
import remark from "lume/plugins/remark.ts";
import sass from "lume/plugins/sass.ts";
import sitemap from "lume/plugins/sitemap.ts";

const site = lume({
	src: "./src",
	location: new URL("https://getchoo.github.io"),
});

site.use(attributes());
site.use(base_path());
site.use(code_highlight());
site.use(date());
site.use(remark());
site.use(sass());
site.use(sitemap());
site.ignore("README.md", "LICENSE", ".gitignore", ".gitattributes");
site.copy("imgs");
site.copy("files");
site.copy("js");
site.copy("favicon.ico");

export default site;
