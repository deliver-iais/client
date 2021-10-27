
// console.log("")
importScripts("https://www.gstatic.com/firebasejs/8.6.1/firebase-app.js");
importScripts("https://www.gstatic.com/firebasejs/8.6.1/firebase-messaging.js");
firebase.initializeApp({
    apiKey: "AIzaSyD-_--oS1VdmgtJ6mCDStZQSPnOP0KZPV4",
    authDomain: "deliver-d705a.firebaseapp.com",
    databaseURL: "https://deliver-d705a.firebaseio.com",
    projectId: "deliver-d705a",
    storageBucket: "deliver-d705a.appspot.com",
    messagingSenderId: "192675293547",
    appId: "1:192675293547:web:0f605a2d72acf1fedb042e",
    measurementId: "G-VGC5KM84G6"
});
const messaging = firebase.messaging();
messaging.setBackgroundMessageHandler(function (payload) {
console.log('notification received: ');
    const promiseChain = clients
        .matchAll({
            type: "window",
            includeUncontrolled: true
        })
        .then(windowClients => {
            for (let i = 0; i < windowClients.length; i++) {
                const windowClient = windowClients[i];
                windowClient.postMessage(payload);
            }
        })
        .then(() => {
            const title = payload.notification.title;
            const options = {
                body: payload.notification.score
              };
            return registration.showNotification(title, options);
        });
    return promiseChain;
});
self.addEventListener('notificationclick', function (event) {
    console.log('notification received: ', event)
});