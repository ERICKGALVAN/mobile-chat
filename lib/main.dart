import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat/modules/auth/pages/login.dart';
import 'package:flutter_chat/modules/home/bloc/groups_cubit/groups_cubit.dart';
import 'package:flutter_chat/modules/home/pages/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';
import 'modules/home/bloc/cotacts_cubit/contacts_cubit.dart';

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  log("Handling a background message");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  bool? isActive = prefs.getBool('isActive');
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  messaging.getToken().then((value) {
    log('token: $value');
  });
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    log('Got a message whilst in the foreground!');
    log('Message data: ${message.messageType}');

    if (message.notification != null) {
      log('Message also contained a notification: ${message.notification!.title}');
    }
  });

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  bool authorized;

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    log('User granted permission');
    authorized = true;
  } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
    log('User granted provisional permission');
    authorized = true;
  } else {
    log('User declined or has not accepted permission');
    authorized = false;
  }
  runApp(
    MyApp(
      isActive: isActive,
      authorized: authorized,
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.isActive,
    required this.authorized,
  });
  final bool? isActive;
  final bool authorized;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ContactsCubit(),
        ),
        BlocProvider(
          create: (context) => GroupsCubit(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          //primaryColor: const Color.fromARGB(255, 144, 55, 218),
          primaryColor: const Color.fromARGB(255, 9, 133, 234),
        ),
        home: MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) => ContactsCubit(),
            ),
            BlocProvider(
              create: (context) => GroupsCubit(),
            ),
          ],
          child: (isActive == false || isActive == null)
              ? const Login()
              : const HomePage(),
        ),
      ),
    );
  }
}
