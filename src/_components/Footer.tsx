import { Data } from "lume/core.ts";

const html = String.raw;

export default ({ gitRevision }: Data) =>
	html`
		<footer>
			<div class="flex">
				<div class="flex flex-col items-center gap-1 p-3 mx-auto">
					<a
						class="text-text text-xs"
						href="https://github.com/getchoo/getchoo.github.io"
						>source</a
					>
					<p class="text-text text-xs">commit: ${gitRevision}</p>
				</div>
			</div>
		</footer>
	`;
