import { defineConfig } from "astro/config";
import sitemap from "@astrojs/sitemap";

// https://astro.build/config
export default defineConfig({
	site: process.env.SITE_URL || process.env.CF_PAGES_URL || "http://my.site",
	integrations: [sitemap()],
	vite: {
		css: {
			transformer: "lightningcss",
		},
	},
});
