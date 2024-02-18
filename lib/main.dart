import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_practice_app/screens/upload_image_screen.dart';
import 'package:firebase_practice_app/services/push_notification_service.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  PushNotificationService().init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: UploadImageScreen.id,
      routes: {UploadImageScreen.id: (context) => UploadImageScreen()},
    );
  }
}
