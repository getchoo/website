import acab from "./acab.gif";
import arnold from "./arnold.gif";
import capitalism from "./capitalism.gif";
import legalize from "./legalize.gif";
import poweredByNix from "./poweredbynix.svg";
import pride from "./pride.gif";
import steam from "./steam.gif";
import weezer from "./weezer.gif";

interface Gif {
	gif: ImageMetadata;
	alt: string;
}

const gifs: Gif[] = [
	{ gif: acab, alt: "ACAB!" },
	{ gif: arnold, alt: "Hey Arnold!" },
	{ gif: capitalism, alt: "Let's crush capitalism!" },
	{ gif: legalize, alt: "Legalize marijuana now!" },
	{ gif: poweredByNix, alt: "Powered by NixOS" },
	{ gif: pride, alt: "LGBTQ Pride now!" },
	{ gif: steam, alt: "Play on Steam!" },
	{ gif: weezer, alt: "Weezer fan" },
];

export default gifs;
