import 'dart:io';

import 'package:autotelematic_new_app/utils/commonutils.dart';
import 'package:autotelematic_new_app/utils/localnotification.dart';
import 'package:autotelematic_new_app/utils/routes/routes.dart';
import 'package:autotelematic_new_app/utils/routes/routes_names.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

@pragma('vm:entry-point')
Future<void> backGroundHandler(RemoteMessage event) async {
  await Firebase.initializeApp();

  //LocalNotificationServices.showNotifiationForground(event);
  if (event.notification != null) {
    LocalNotificationServices.showNotifiationForground(event);
    CommonUtils.toastMessage(event.notification.toString());
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FirebaseOptions firebaseOptions = const FirebaseOptions(
    apiKey: '',
    appId: '',
    messagingSenderId: '',
    projectId: '',
  );
  if (Platform.isAndroid) {
    firebaseOptions = const FirebaseOptions(
      apiKey:
          "AIzaSyBpfZhjrkjeS-nkP-yAj-JmbrZ7j1NfVyE", //*** API can be found in FCM google JSON file
      appId: "1:906985510839:android:ed1f651158bb96f7b3ba32",
      messagingSenderId: "906985510839",
      projectId: "tracknowpk-1cadd",
    );
  } else if (Platform.isIOS) {
    firebaseOptions = const FirebaseOptions(
      apiKey: 'AIzaSyCr18uJPowZZFyoBcPWTqIDQ7lRmtxovZk',
      appId: '1:906985510839:ios:e32d41035e594d12b3ba32',
      messagingSenderId: '906985510839',
      projectId: 'tracknowpk-1cadd',
    );
  }

  await Firebase.initializeApp(
    name: 'Nostrum_Track',
    options: firebaseOptions,
  );
  FirebaseMessaging.instance.requestPermission();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
            //  seedColor: const Color.fromARGB(255, 255, 166, 2),
            seedColor: Colors.blue,
            brightness: Brightness.light),
        primarySwatch: Colors.blue,
      ),
      initialRoute: RoutesName.splashSceen,
      onGenerateRoute: Routes.generateRoute,
    );
  }
}
