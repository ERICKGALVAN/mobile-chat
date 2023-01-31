import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_chat/modules/auth/services/database_service.dart';
import 'package:flutter_chat/widgets/main_button.dart';

class ChatInfo extends StatefulWidget {
  const ChatInfo({
    Key? key,
    required this.contactName,
    required this.userId,
    required this.contactId,
  }) : super(key: key);
  final String userId;
  final String contactName;
  final String contactId;

  @override
  State<ChatInfo> createState() => _ChatInfoState();
}

class _ChatInfoState extends State<ChatInfo> {
  bool _isLoading = false;
  String getName(String value) {
    return value.split('_')[1];
  }

  Future _addContact() async {
    setState(() {
      _isLoading = true;
    });
    await DatabaseService()
        .sendRequest(widget.userId, widget.contactId)
        .then((value) {
      log(value.toString());
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Solicitud enviada'),
        ),
      );
    }).catchError((e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al enviar solicitud'),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
        ),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor,
              ),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    Text(widget.contactName),
                    Text(widget.contactId),
                    Text(widget.userId),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: const Color.fromARGB(255, 236, 236, 236)
                                .withOpacity(0.5),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    MainButton(
                      text: 'Añadir contacto',
                      onPressed: () async {
                        await _addContact();
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
