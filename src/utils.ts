export const toNiceDateString = (date: Date) =>
	date.toLocaleString("en", {
		dateStyle: "full",
		// NOTE: Usually this would vary by the system building the website
		// So, set it explicitly
		timeZone: "UTC",
	});
