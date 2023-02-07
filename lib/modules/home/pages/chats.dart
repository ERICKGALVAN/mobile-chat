import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat/modules/chat/pages/chat_page.dart';
import 'package:flutter_chat/modules/home/bloc/cotacts_cubit/contacts_cubit.dart';

import '../../../widgets/chat_container.dart';

class Chats extends StatefulWidget {
  const Chats({
    Key? key,
  }) : super(key: key);

  @override
  State<Chats> createState() => _ChatsState();
}

class _ChatsState extends State<Chats> {
  String getGroupId(String value) {
    return value.split('_')[0];
  }

  String getGroupName(String value) {
    return value.split('_')[1];
  }

  Future getNames(String uid) async {
    final ChatsBloc = BlocProvider.of<ContactsCubit>(context);
    if (ChatsBloc.state is LoadedState) {
      if (ChatsBloc.friends == null) {}
    }
  }

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
                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatPage(
                              chatId: snapshot.data!['chats'][index]['chatId'],
                              contactName: snapshot.data!['chats'][index]
                                  ['chatWith']['name'],
                            ),
                          ),
                        );
                      },
                      child: StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection('messages')
                            .doc(snapshot.data!['chats'][index]['chatId'])
                            .snapshots(),
                        builder: (context, chatSnapshot) {
                          return ChatContainer(
                            groupName: snapshot.data!['chats'][index]
                                    ['chatWith']['name']
                                .toString(),
                            message: chatSnapshot.hasData
                                ? chatSnapshot.data!['recentMessage'].toString()
                                : '',
                            lastSenderEmail: chatSnapshot.hasData
                                ? chatSnapshot.data!['recentMessageSenderEmail']
                                    .toString()
                                : '',
                            lastSenderName: chatSnapshot.hasData
                                ? chatSnapshot.data!['recentMessageSender']
                                    .toString()
                                : '',
                            isGroup: false,
                          );
                        },
                      ),
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
