import 'package:firebase_messaging/firebase_messaging.dart';

Future<void> firebaMessagingBackgroundHandler(RemoteMessage message) async {
  print(message.notification!.title);
}

class PushNotificationService {
  FirebaseMessaging fcm = FirebaseMessaging.instance;

  void init() async {
    await fcm.requestPermission();
    final fcmToken = await fcm.getToken();
    print(fcmToken);
    FirebaseMessaging.onBackgroundMessage(firebaMessagingBackgroundHandler);
    FirebaseMessaging.onMessage.listen((event) {});
  }
}

//Firebase
//Firebase Auth
//Firebase Firestore
//Firebase Storage
//Firebase Messaging
