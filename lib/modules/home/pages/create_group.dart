import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat/modules/auth/services/database_service.dart';
import 'package:flutter_chat/widgets/main_button.dart';
import 'package:flutter_chat/widgets/main_input.dart';

class CreateGroup extends StatefulWidget {
  const CreateGroup({
    Key? key,
    required this.userName,
  }) : super(key: key);
  final String userName;

  @override
  State<CreateGroup> createState() => _CreateGroupState();
}

class _CreateGroupState extends State<CreateGroup> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text('Crear grupo'),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor,
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Nombre del grupo',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  MainInput(
                    hintText: 'Nombre del grupo',
                    controller: _nameController,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Descripción del grupo',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  MainInput(
                    hintText: 'Descripción del grupo',
                    controller: _descriptionController,
                  ),
                  const SizedBox(height: 20),
                  MainButton(
                    text: 'Crear',
                    onPressed: () async {
                      if (_nameController.text.isNotEmpty) {
                        setState(() {
                          _isLoading = true;
                        });
                        await DatabaseService(
                                uid: FirebaseAuth.instance.currentUser!.uid)
                            .createGroup(
                          widget.userName,
                          FirebaseAuth.instance.currentUser!.uid,
                          _nameController.text,
                          _descriptionController.text,
                        )
                            .whenComplete(() {
                          setState(() {
                            _isLoading = false;
                          });
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Grupo creado correctamente'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
    );
  }
}
