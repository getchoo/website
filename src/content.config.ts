import { defineCollection, z } from "astro:content";
import { glob } from "astro/loaders";

const blog = defineCollection({
	loader: glob({ pattern: "**.md", base: "./src/blog" }),
	schema: z.object({
		title: z.string(),
		description: z.string(),
		draft: z.boolean().default(false),
		publishedDate: z.date(),
		lastEditedDate: z.date().optional(),
		image: z
			.object({
				name: z.string(),
				alt: z.string(),
			})
			.optional(),
	}),
});

export const collections = { blog };
