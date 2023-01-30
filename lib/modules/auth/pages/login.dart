import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat/modules/auth/pages/sign_up.dart';
import 'package:flutter_chat/modules/auth/services/database_service.dart';
import 'package:flutter_chat/modules/home/pages/home_page.dart';
import 'package:flutter_chat/widgets/main_button.dart';
import 'package:flutter_chat/widgets/main_input.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/auth_service.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  Future<void> _loginWithEmail() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isLoading = true;
    });
    await AuthService()
        .loginWithEmail(_emailController.text, _passwordController.text)
        .then((value) async {
      if (value == null) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Usuario no encontrado'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
          .getUserData(value)
          .then((value) {
        setState(() {
          _isLoading = false;
        });

        prefs.setString('name', value.docs[0]['name']);
        prefs.setString('email', value.docs[0]['email']);
        prefs.setBool('isActive', true);
        if (context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const HomePage(),
            ),
          );
        }
      });
    }).catchError((error) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString()),
        ),
      );
    });
  }

  Future<void> _googleSignIn() async {
    if (await AuthService().googleAuth()) {
      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const HomePage(),
          ),
        );
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al iniciar sesión'),
          ),
        );
      }
    }
  }

  bool _isLoading = false;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 100),
                    const Text(
                      'login',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    MainInput(
                      hintText: 'Correo electrónico',
                      controller: _emailController,
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 20),
                    MainInput(
                      hintText: 'Contraseña',
                      controller: _passwordController,
                      icon: Icons.lock,
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                    ),
                    const SizedBox(height: 20),
                    MainButton(
                      onPressed: () async {
                        await _loginWithEmail();
                      },
                      text: 'Iniciar sesión',
                    ),
                    const SizedBox(height: 40),
                    const Divider(
                      thickness: 0.5,
                      color: Colors.black,
                    ),
                    const SizedBox(height: 40),
                    MainButton(
                      onPressed: () async {
                        await _googleSignIn();
                      },
                      text: 'Inicio de sesión con Google',
                      backgroundColor: const Color.fromRGBO(198, 54, 43, 1),
                    ),
                    const SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('¿No tienes una cuenta?'),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SignUp(),
                              ),
                            );
                          },
                          child: Text(
                            'Regístrate',
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
