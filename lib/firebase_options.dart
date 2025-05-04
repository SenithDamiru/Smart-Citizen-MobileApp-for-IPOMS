import 'package:firebase_core/firebase_core.dart';

class DefaultFirebaseOptions {
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCES0imbXBn0yrxxyq7WFoP43xhUKoRWNw',
    appId: '1:852218509773:android:a013b49a12b78c09aaec84',
    messagingSenderId: '852218509773',
    projectId: 'smart-citizen-cbea9',
    storageBucket: 'smart-citizen-cbea9.firebasestorage.app', // Updated for consistency
  );

  static FirebaseOptions get currentPlatform => android; // Always returns Android options
}
