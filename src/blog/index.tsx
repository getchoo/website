import { Data } from "lume/core.ts";
import { Props } from "@utils/types.ts";

export const layout = "layouts/Page.tsx";
export const title = "getchoo's blog";
export const description = "getchoo's blog posts";

const html = String.raw;

export default ({ search, filters }: Props) => {
	const posts = search.pages("type=posts", "date=desc") as Data[];
	return html`
		<div>
			<ul class="postList">
				${posts.map((post: Data) => {
					const url = post.data.url ? post.data.url : "/";

					return html`
						<li>
							<a href=${url}>${post.data.title}</a>
						</li>
					`;
				})}
			</ul>
		</div>
	`;
};
