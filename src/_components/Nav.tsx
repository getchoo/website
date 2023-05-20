interface Links {
	home: string;
	blog: string;
	forgejo: string;
	grafana: string;
	github: string;
}

const links: Links = {
	home: "/",
	blog: "/blog",
	forgejo: "https://git.mydadleft.me/",
	grafana: "https://grafana.mydadleft.me/",
	github: "https://github.com/getchoo",
};

const html = String.raw;

export default html`
	<nav>
		<div class="flex flex-column justify-center mx-auto p-5">
			<ul class="inline">
				${Object.entries(links)
					.map(
						([link, url]) =>
							html`
								<li class="inline text-base p-2">
									<a
										class="rounded-xl bg-yellow p-2"
										href=${url}
										>${link}</a
									>
								</li>
							`
					)
					.join("\n")}
			</ul>
		</div>
	</nav>
`;
