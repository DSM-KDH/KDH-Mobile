import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions are not configured for web.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not configured for $defaultTargetPlatform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA5HRBiEVihcIybVZD1VIqrzD3uMMXOXVk',
    appId: '1:645361727447:android:5d3269b8f0f89b529b3d92',
    messagingSenderId: '645361727447',
    projectId: 'kdh-fcm',
    storageBucket: 'kdh-fcm.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCdqjDjTKv-a31HbNwsXyi9W14aGAN7mz4',
    appId: '1:645361727447:ios:8c25f691b21971d99b3d92',
    messagingSenderId: '645361727447',
    projectId: 'kdh-fcm',
    storageBucket: 'kdh-fcm.firebasestorage.app',
    iosBundleId: 'com.example.kdhMobile',
  );
}
