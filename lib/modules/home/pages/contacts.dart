import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../widgets/chat_container.dart';
import '../../auth/services/database_service.dart';

class Contacts extends StatefulWidget {
  const Contacts({Key? key}) : super(key: key);

  @override
  State<Contacts> createState() => _ContactsState();
}

class _ContactsState extends State<Contacts> {
  @override
  void initState() {
    getUserData();
    super.initState();
  }

  String getGroupId(String value) {
    return value.split('_')[0];
  }

  String getGroupName(String value) {
    return value.split('_')[1];
  }

  Future<void> getUserData() async {
    setState(() {
      _isLoading = true;
    });
    await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
        .getUserFriends()
        .then((value) {
      log(value.toString());
      setState(() {
        _friendsAux = value;
      });
    });

    for (var i = 0; i < _friendsAux.length; i++) {
      await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
          .findUserById(_friendsAux[i])
          .then((value) {
        setState(() {
          _friends.add(value.data());
        });
      });
    }
    log(_friends.toString());

    setState(() {
      _isLoading = false;
    });
  }

  List _friendsAux = [];
  final List _friends = [];
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Center(
            child: CircularProgressIndicator(
              color: Theme.of(context).primaryColor,
            ),
          )
        : ListView.builder(
            itemCount: _friends.length,
            itemBuilder: (context, index) {
              return ChatContainer(
                groupName: _friends[index]['name'],
                message: _friends[index]['email'],
              );
            },
          );
  }
}
