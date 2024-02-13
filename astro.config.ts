import { defineConfig } from "astro/config";
import mdx from "@astrojs/mdx";
import sitemap from "@astrojs/sitemap";
import tailwind from "@astrojs/tailwind";

const site =
	process.env.SITE_URL || process.env.CF_PAGES_URL || "https://my.site";

// https://astro.build/config
export default defineConfig({
	site,
	integrations: [mdx(), sitemap(), tailwind()],
});
