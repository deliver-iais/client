importScripts('https://www.gstatic.com/firebasejs/8.6.1/firebase-app.js');
importScripts('https://www.gstatic.com/firebasejs/8.6.1/firebase-messaging.js');


/*Update with yours config*/
const firebaseConfig = {
    apiKey: "AIzaSyD-_--oS1VdmgtJ6mCDStZQSPnOP0KZPV4",
    authDomain: "deliver-d705a.firebaseapp.com",
    databaseURL: "https://deliver-d705a.firebaseio.com",
    projectId: "deliver-d705a",
    storageBucket: "deliver-d705a.appspot.com",
    messagingSenderId: "192675293547",
    appId: "1:192675293547:web:0f605a2d72acf1fedb042e",
    measurementId: "G-VGC5KM84G6"
};

// noinspection JSUnresolvedVariable
firebase.initializeApp(firebaseConfig);

// noinspection JSUnresolvedVariable
const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
    console.log('[firebase-messaging-sw.js] Received background message ', payload);
    // Customize notification here

    const res = window.decodeMessageForCallFromJs(payload);
    if (res != null) {
        const roomName = res['title'];
        const body = res['body'];
        if (roomName != null && body != null) {
            const notificationTitle = roomName;
            const notificationOptions = {
                body: body,
                icon: 'icons/ic_launcher.png'
            };
            // noinspection JSIgnoredPromiseFromCall
            self.registration.showNotification(notificationTitle,
                notificationOptions);
        }
    }

});




