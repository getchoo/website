/** @type {import('tailwindcss').Config} */
module.exports = {
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
		require("@catppuccin/tailwindcss")({
			defaultFlavour: "mocha",
		}),
	],
};
