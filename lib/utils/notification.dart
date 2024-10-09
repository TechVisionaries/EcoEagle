import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> requestNotificationPermissions() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    print('User granted permission');
  } else {
    print('User declined or has not accepted permission');
  }
}

Future<void> saveTokenToDatabase(String uid) async {
  String? token = await FirebaseMessaging.instance.getToken();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // String uid = FirebaseAuth.instance.currentUser!.uid;

  if (token != null) {
    await _firestore.collection('users').doc(uid).set({
      'fcmToken': token,
    });
  }
}

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
}

