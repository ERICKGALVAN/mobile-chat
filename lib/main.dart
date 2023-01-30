import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat/modules/auth/pages/login.dart';
import 'package:flutter_chat/modules/home/pages/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  bool? isActive = prefs.getBool('isActive');
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp(
    isActive: isActive,
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.isActive,
  });
  final bool? isActive;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color.fromARGB(255, 144, 55, 218),
      ),
      home: (isActive == false || isActive == null)
          ? const Login()
          : const HomePage(),
    );
  }
}
