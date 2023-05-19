import { Props } from "@utils/types.ts";

const html = String.raw;

export default ({ title, description }: Props) =>
	html`
		<head>
			<meta charset="utf-8" />
			<meta http-equiv="X-UA-Compatible" content="IE=edge" />
			<title>${title}</title>
			<meta name="description" content=${description} />
			<meta
				name="viewport"
				content="width=device-width, initial-scale=1"
			/>
			<link rel="stylesheet" href="/global.css" />
		</head>
	`;
