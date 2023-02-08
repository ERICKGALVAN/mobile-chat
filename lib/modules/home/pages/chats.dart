import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat/modules/chat/pages/chat_page.dart';

import '../../../widgets/chat_container.dart';

class Chats extends StatefulWidget {
  const Chats({
    Key? key,
  }) : super(key: key);

  @override
  State<Chats> createState() => _ChatsState();
}

class _ChatsState extends State<Chats> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return snapshot.data!['chats'].isEmpty
              ? const Center(
                  child: Text(
                    'No tienes contactos aún',
                  ),
                )
              : ListView.builder(
                  itemCount: snapshot.data!['chats'].length,
                  itemBuilder: (context, index) {
                    final chatWithId = snapshot.data!['chats'][index]
                            ['chatWith']['uid']
                        .toString();
                    return StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('messages')
                          .doc(snapshot.data!['chats'][index]['chatId'])
                          .snapshots(),
                      builder: (context, chatSnapshot) {
                        log(snapshot.data!.exists.toString());
                        return InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatPage(
                                  chatId: snapshot.data!['chats'][index]
                                      ['chatId'],
                                  contactName: snapshot.data!['chats'][index]
                                      ['chatWith']['name'],
                                  contactId: chatWithId,
                                ),
                              ),
                            );
                          },
                          child: StreamBuilder(
                              stream: FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(snapshot.data!['chats'][index]
                                      ['chatWith']['uid'])
                                  .snapshots(),
                              builder: (context, picSnapshot) {
                                return ChatContainer(
                                  photoUrl: picSnapshot.hasData
                                      ? picSnapshot.data!['photoURL'].toString()
                                      : '',
                                  groupName: snapshot.data!['chats'][index]
                                          ['chatWith']['name']
                                      .toString(),
                                  message: chatSnapshot.hasData
                                      ? chatSnapshot.data!['recentMessage']
                                          .toString()
                                      : '',
                                  lastSenderEmail: chatSnapshot.hasData
                                      ? chatSnapshot
                                          .data!['recentMessageSenderEmail']
                                          .toString()
                                      : '',
                                  lastSenderName: chatSnapshot.hasData
                                      ? chatSnapshot
                                          .data!['recentMessageSender']
                                          .toString()
                                      : '',
                                  isGroup: false,
                                  isTyping: chatSnapshot.hasData
                                      ? chatSnapshot
                                          .data!['${chatWithId}isTyping']
                                      : false,
                                );
                              }),
                        );
                      },
                    );
                  },
                );
        } else {
          return const Center(
            child: Center(
              child: CircularProgressIndicator(
                color: Colors.red,
              ),
            ),
          );
        }
      },
    );
  }
}
