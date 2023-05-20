import { PageData } from "lume/core.ts";

export const layout = "layouts/Base.tsx";
const html = String.raw;

export default ({ content }: PageData) =>
	html`
		<div class="container">
			<div class="content" id="blogpost">${content}</div>
		</div>
	`;
