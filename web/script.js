const isSupported = () =>
    'Notification' in window &&
    'serviceWorker' in navigator &&
    'PushManager' in window

function showNotification(roomName, message) {
    if (!isSupported()) {
        return;
    }
    // Let's check if the browser supports notifications
    if (!("Notification" in window)) {
        alert("This browser does not support desktop notification");
    }

    // Let's check whether notification permissions have already been granted
    else if (Notification.permission === "granted") {
        // If it's okay let's create a notification
        var notification = new Notification(roomName, {
            body: message,
            icon: "icons/ic_launcher.png"
        });
    }

    // Otherwise, we need to ask the user for permission
    else if (Notification.permission !== "denied") {
        Notification.requestPermission().then(function (permission) {
            // If the user accepts, let's create a notification
            if (permission === "granted") {
                var notification = new Notification(roomName, {
                    body: message,
                    icon: "icons/ic_launcher.png"
                });
            }
        });
    }

    // At last, if the user has denied notifications, and you
    // want to be respectful there is no need to bother them any more.
}

function getNotificationPermission() {
    if (!isSupported()) {
        return;
    }
    if (Notification.permission !== "denied") {
        Notification.requestPermission();
    }
}

let deferredPrompt;

// add to homescreen
window.addEventListener("beforeinstallprompt", (e) => {
    // Prevent Chrome 67 and earlier from automatically showing the prompt
    e.preventDefault();
    // Stash the event so it can be triggered later.
    deferredPrompt = e;

});

function isDeferredNotNull() {
    return deferredPrompt != null;
}

function presentAddToHome() {
    if (deferredPrompt != null) {
        // Update UI to notify the user they can add to home screen
        // Show the prompt
        deferredPrompt.prompt();
        // Wait for the user to respond to the prompt
        deferredPrompt.userChoice.then((choiceResult) => {
            if (choiceResult.outcome === "accepted") {
                console.log("User accepted the A2HS prompt");
            } else {
                console.log("User dismissed the A2HS prompt");
            }
            deferredPrompt = null;
        });
    } else {
        console.log("deferredPrompt is null");
        return null;
    }
}
