import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat/modules/chat/pages/chat_info.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({
    Key? key,
    required this.userName,
    required this.contactName,
  }) : super(key: key);

  final String userName;
  final String contactName;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  Stream<QuerySnapshot>? _chats;
  String _admin = '';
  List _groupMembers = [];
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(widget.contactName),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return ChatInfo(
                      contactId: widget.userName,
                      contactName: widget.contactName,
                      userId: widget.userName,
                    );
                  },
                ),
              );
            },
            icon: const Icon(
              Icons.info,
            ),
          ),
        ],
      ),
      body: Center(
        child: Text(widget.contactName),
      ),
    );
  }
}
