import { defineConfig } from "astro/config";

import sitemap from "@astrojs/sitemap";

// https://astro.build/config
export default defineConfig({
	site: process.env.CF_PAGES_URL || "https://getchoo.com",
	integrations: [sitemap()],
});
