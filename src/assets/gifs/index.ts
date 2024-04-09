import acab from "./acab.gif";
import arnold from "./arnold.gif";
import capitalism from "./capitalism.gif";
import legalize from "./legalize.gif";
import poweredByNix from "./poweredbynix.svg";
import pride from "./pride.gif";
import steam from "./steam.gif";
import weezer from "./weezer.gif";

interface Gif {
	image: ImageMetadata;
	alt: string;
}

const gifs: Gif[] = [
	{ image: acab, alt: "ACAB!" },
	{ image: arnold, alt: "Hey Arnold!" },
	{ image: capitalism, alt: "Let's crush capitalism!" },
	{ image: legalize, alt: "Legalize marijuana now!" },
	{ image: poweredByNix, alt: "Powered by NixOS" },
	{ image: pride, alt: "LGBTQ Pride now!" },
	{ image: steam, alt: "Play on Steam!" },
	{ image: weezer, alt: "Weezer fan" },
];

export default gifs;
