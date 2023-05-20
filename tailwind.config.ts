/** @type {module} */
/** @type {import('tailwindcss').Config} */

import type { Config } from "tailwindcss";
import tailwind from "@catppuccin/tailwindcss";

export default {
	content: ["./src/**/*.{astro,html,js,jsx,md,mdx,svelte,ts,tsx,vue}"],
	theme: {
		fontFamily: {
			sans: ["Noto Sans", "sans-serif"],
			serif: ["Noto Serif", "serif"],
			monospace: ["Fira Code", "monospace"],
		},
		extend: {},
	},
	plugins: [
		tailwind({
			defaultFlavour: "mocha",
		}),
	],
} satisfies Config;
