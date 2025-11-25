import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

Future initFirebase() async {
  if (kIsWeb) {
    await Firebase.initializeApp(
        options: FirebaseOptions(
            apiKey: "AIzaSyCRqnVeBeyvI0UwT5YJW6pljqaIN69xnls",
            authDomain: "kwanza-lova.firebaseapp.com",
            projectId: "kwanza-lova",
            storageBucket: "kwanza-lova.firebasestorage.app",
            messagingSenderId: "601876218581",
            appId: "1:601876218581:web:e77be254dda4ce16f9585c",
            measurementId: "G-B5F39SJLNH"));
  } else {
    await Firebase.initializeApp();
  }
}
