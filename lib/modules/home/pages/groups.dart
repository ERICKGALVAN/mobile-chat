import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../widgets/chat_container.dart';
import '../../chat_group/pages/chat_group_page.dart';

class Groups extends StatefulWidget {
  const Groups({Key? key}) : super(key: key);

  @override
  State<Groups> createState() => _GroupsState();
}

class _GroupsState extends State<Groups> {
  @override
  void didChangeDependencies() async {
    final prefs = await SharedPreferences.getInstance();
    _name = prefs.getString('name');
    _email = prefs.getString('email');

    super.didChangeDependencies();
  }

  String getGroupId(String value) {
    return value.split('_')[0];
  }

  String getGroupName(String value) {
    return value.split('_')[1];
  }

  String? _name = '';
  String? _email = '';

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              color: Theme.of(context).primaryColor,
            ),
          );
        }
        return ListView.builder(
          physics: const BouncingScrollPhysics(),
          itemCount: snapshot.data!['groups'].length,
          itemBuilder: (context, index) {
            int reversedIndex = snapshot.data!['groups'].length - index - 1;
            return StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('groups')
                  .doc(getGroupId(snapshot.data!['groups'][reversedIndex]))
                  .snapshots(),
              builder: (context, groupSnapshot) {
                return InkWell(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatGroupPage(
                        groupId:
                            getGroupId(snapshot.data!['groups'][reversedIndex]),
                        groupName: getGroupName(
                            snapshot.data!['groups'][reversedIndex]),
                        userName: _name ?? '',
                        userEmail: _email ?? '',
                        profilePic: groupSnapshot.hasData
                            ? groupSnapshot.data!['groupIcon']
                            : '',
                      ),
                    ),
                  ),
                  child: ChatContainer(
                    photoUrl: groupSnapshot.hasData
                        ? groupSnapshot.data!['groupIcon']
                        : '',
                    groupName:
                        getGroupName(snapshot.data!['groups'][reversedIndex]),
                    lastSenderEmail: groupSnapshot.hasData
                        ? groupSnapshot.data!['recentMessageSender']
                        : '',
                    lastSenderName: groupSnapshot.hasData
                        ? groupSnapshot.data!['recentMessageSender']
                        : '',
                    isGroup: true,
                    isTyping: false,
                    message: groupSnapshot.hasData
                        ? groupSnapshot.data!['recentMessage']
                        : '',
                    showUserName: true,
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
