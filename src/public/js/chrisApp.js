const chrisURL = "/imgs/chris/";

function randomChris() {
	const files = [
		"chis_very_fried.jpg",
		"chris_medium_fried.jpg",
		"chris_moshed.jpg",
		"fried_publisher.jpg",
		"help_me.png",
		"nice_chris.png",
		"nice_publisher.png",
		"bkender_bauob.jpg",
		"blurry_chris.jpg",
	];

	// this chooses a random file from the array
	const url = chrisURL + files[Math.floor(Math.random() * files.length)];

	window.location.href = url;
}

function findChris() {
	const chris = document.getElementById("chris_gif");
	chris
		? chris.addEventListener("click", randomChris)
		: console.warn("Couldn't load chris app!");
}

// avoiding a race condition here
setTimeout(findChris, 1000);
