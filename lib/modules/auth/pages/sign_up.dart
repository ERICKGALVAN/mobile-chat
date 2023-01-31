import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat/modules/auth/pages/login.dart';
import 'package:flutter_chat/modules/home/pages/home_page.dart';
import 'package:flutter_chat/widgets/main_button.dart';
import 'package:flutter_chat/widgets/main_input.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/auth_service.dart';
import '../services/database_service.dart';

class SignUp extends StatefulWidget {
  const SignUp({Key? key}) : super(key: key);

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  Future<void> _signUp() async {
    setState(() {
      _isLoading = true;
    });
    final prefs = await SharedPreferences.getInstance();
    await AuthService()
        .registerWithEmailAndPassword(_nameController.text,
            _emailController.text, _passwordController.text)
        .then((value) async {
      setState(() {
        _isLoading = false;
      });
      if (value.runtimeType == bool) {
        if (value) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Registro exitoso'),
              backgroundColor: Colors.green,
            ),
          );

          await AuthService()
              .loginWithEmail(_emailController.text, _passwordController.text);

          await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
              .getUserData(value)
              .then(
            (value) {
              setState(() {
                _isLoading = false;
              });
              prefs.setBool('isActive', true);

              prefs.setString('name', value.docs[0]['name']);
              prefs.setString('email', value.docs[0]['email']);
              if (context.mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HomePage(),
                  ),
                );
              }
            },
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(value.toString()),
          ),
        );
      }
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
  final _nameController = TextEditingController();
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
                      'Flutter Chat',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    MainInput(
                      hintText: 'Nombre de usuario',
                      controller: _nameController,
                    ),
                    const SizedBox(height: 20),
                    MainInput(
                      hintText: 'Correo electrónico',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 20),
                    MainInput(
                      hintText: 'Contraseña',
                      controller: _passwordController,
                      icon: Icons.lock,
                      obscureText: true,
                    ),
                    const SizedBox(height: 20),
                    MainButton(
                      onPressed: () async {
                        await _signUp();
                      },
                      text: 'Registrarse',
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
                        const Text('¿Ya tienes una cuenta?'),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const Login(),
                              ),
                            );
                          },
                          child: Text(
                            'Inicia sesión',
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
