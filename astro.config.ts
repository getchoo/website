import { defineConfig } from "astro/config";

import sitemap from "@astrojs/sitemap";

import tailwindcss from "@tailwindcss/vite";

// https://astro.build/config
export default defineConfig({
	site: process.env.CF_PAGES_URL || "https://getchoo.com",
	integrations: [sitemap()],
	vite: {
		plugins: [tailwindcss()],
	},
});
