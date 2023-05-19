export const title = "fard";
export const layout = "layouts/Base.tsx";
const html = String.raw;

export default html`
	<div class="flex justify-center p-5">
		<video width="1280" height="720" controls autoplay muted>
			<source src="/files/rickroll.mp4" type="video/mp4" />
		</video>
	</div>
`;
