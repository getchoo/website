import { defineConfig } from "astro/config";
import image from "@astrojs/image";
import sitemap from "@astrojs/sitemap";
import tailwind from "@astrojs/tailwind";

export default defineConfig({
	site: "https://mydadleft.me",
	integrations: [
		image({
			serviceEntryPoint: "@astrojs/image/sharp",
		}),
		sitemap(),
		tailwind(),
	],
});
