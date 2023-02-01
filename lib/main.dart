import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat/modules/auth/pages/login.dart';
import 'package:flutter_chat/modules/home/bloc/groups_cubit/groups_cubit.dart';
import 'package:flutter_chat/modules/home/pages/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';
import 'modules/home/bloc/cotacts_cubit/contacts_cubit.dart';

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
      darkTheme: ThemeData.dark(),
      theme: ThemeData(
        //primaryColor: const Color.fromARGB(255, 144, 55, 218),
        primaryColor: Colors.black,
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
    );
  }
}
