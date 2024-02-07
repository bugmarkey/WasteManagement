import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAzlTk3LCP97b15xz_Z1FLK2pC7NoL3i6w',
    appId: '1:236584419816:web:8b8d2456d515cc0553245d',
    messagingSenderId: '236584419816',
    projectId: 'smartbin-96489',
    authDomain: 'smartbin-96489.firebaseapp.com',
    databaseURL:
        'https://smartbin-96489-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'smartbin-96489.appspot.com',
    measurementId: 'G-0VSX6FRH6R',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAGKX6hC5v6jaGjDHsx2LY0554Nd3FKI7k',
    appId: '1:236584419816:android:f5a80fbca324df0453245d',
    messagingSenderId: '236584419816',
    projectId: 'smartbin-96489',
    databaseURL:
        'https://smartbin-96489-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'smartbin-96489.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAnCC0jvgrzTQhd45htFgIWy1iOdpYt-oM',
    appId: '1:236584419816:ios:ae387b9b1ca1d97d53245d',
    messagingSenderId: '236584419816',
    projectId: 'smartbin-96489',
    databaseURL:
        'https://smartbin-96489-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'smartbin-96489.appspot.com',
    iosClientId:
        '236584419816-fd4s37fumo7h7jbqqba1eh09h3apvgdk.apps.googleusercontent.com',
    iosBundleId: 'com.example.smartBinNew',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAnCC0jvgrzTQhd45htFgIWy1iOdpYt-oM',
    appId: '1:236584419816:ios:ae387b9b1ca1d97d53245d',
    messagingSenderId: '236584419816',
    projectId: 'smartbin-96489',
    databaseURL:
        'https://smartbin-96489-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'smartbin-96489.appspot.com',
    iosClientId:
        '236584419816-fd4s37fumo7h7jbqqba1eh09h3apvgdk.apps.googleusercontent.com',
    iosBundleId: 'com.example.smartBinNew',
  );
}
