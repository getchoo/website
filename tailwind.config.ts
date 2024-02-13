import type { Config } from "tailwindcss";
import defaultTheme from "tailwindcss/defaultTheme";

export default {
	content: ["./src/**/*.{astro,html,js,jsx,md,mdx,svelte,ts,tsx,vue}"],
	theme: {
		fontFamily: {
			sans: ["Noto Sans", ...defaultTheme.fontFamily.sans],
			serif: ["Noto Serif", ...defaultTheme.fontFamily.serif],
			monospace: ["Noto Sans Mono", ...defaultTheme.fontFamily.mono],
		},
		extend: {},
	},
	plugins: [
		require("@catppuccin/tailwindcss")({
			defaultFlavour: "mocha",
		}),
	],
} satisfies Config;
