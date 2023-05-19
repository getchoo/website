import { Data } from "lume/core.ts";
import { Props } from "@utils/types.ts";

const html = String.raw;

export default (
	{ comp, content, description, title }: Props,
	{ gitRevision }: Data
) =>
	html`
		<html lang="en">
			${comp.Head({ title: title, description: description })}
			<body class="bg-base">
				${comp.Nav()} ${content} ${comp.Footer(gitRevision)}
			</body>
		</html>
	`;
