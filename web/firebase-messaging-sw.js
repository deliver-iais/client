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
}
  firebase.initializeApp(firebaseConfig);
  const messaging = firebase.messaging();

  /*messaging.onMessage((payload) => {
  console.log('Message received. ', payload);*/
  messaging.onBackgroundMessage(function(payload) {
    console.log('Received background message ', payload);

    const notificationTitle = payload.notification.title;
    const notificationOptions = {
      body: payload.notification.body,
    };

    self.registration.showNotification(notificationTitle,
      "test notification........");
  });

   




