// File generated by FlutterFire CLI.
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.fuchsia:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for fuchsia - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyD-_--oS1VdmgtJ6mCDStZQSPnOP0KZPV4',
    appId: '1:192675293547:web:0f605a2d72acf1fedb042e',
    messagingSenderId: '192675293547',
    projectId: 'deliver-d705a',
    authDomain: 'deliver-d705a.firebaseapp.com',
    databaseURL: 'https://deliver-d705a.firebaseio.com',
    storageBucket: 'deliver-d705a.appspot.com',
    measurementId: 'G-VGC5KM84G6',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBsOupIsPBuSkEziy7azdTgIlJ4e1dp1bQ',
    appId: '1:192675293547:android:da0e239d7495d09ddb042e',
    messagingSenderId: '192675293547',
    projectId: 'deliver-d705a',
    databaseURL: 'https://deliver-d705a.firebaseio.com',
    storageBucket: 'deliver-d705a.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCvaoZDJYin7AXJnP52P6RbcJIfd6kQpmI',
    appId: '1:192675293547:ios:acbc2478604593f8db042e',
    messagingSenderId: '192675293547',
    projectId: 'deliver-d705a',
    databaseURL: 'https://deliver-d705a.firebaseio.com',
    storageBucket: 'deliver-d705a.appspot.com',
    androidClientId:
        '192675293547-rqr50h441m0on66gegre58assn1cl8f8.apps.googleusercontent.com',
    iosClientId:
        '192675293547-v07di0gbgk0modtv9usvucsu56bb3dft.apps.googleusercontent.com',
    iosBundleId: 'ir.we.deliver',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCvaoZDJYin7AXJnP52P6RbcJIfd6kQpmI',
    appId: '1:192675293547:ios:acbc2478604593f8db042e',
    messagingSenderId: '192675293547',
    projectId: 'deliver-d705a',
    databaseURL: 'https://deliver-d705a.firebaseio.com',
    storageBucket: 'deliver-d705a.appspot.com',
    androidClientId:
        '192675293547-rqr50h441m0on66gegre58assn1cl8f8.apps.googleusercontent.com',
    iosClientId:
        '192675293547-v07di0gbgk0modtv9usvucsu56bb3dft.apps.googleusercontent.com',
    iosBundleId: 'ir.we.deliver',
  );
}
