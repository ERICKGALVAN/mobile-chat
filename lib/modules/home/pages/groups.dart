import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../widgets/chat_container.dart';
import '../../auth/services/database_service.dart';
import '../../chat_group/pages/chat_group_page.dart';

class Groups extends StatefulWidget {
  const Groups({Key? key}) : super(key: key);

  @override
  State<Groups> createState() => _GroupsState();
}

class _GroupsState extends State<Groups> {
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
        .getUserGroups()
        .then((value) {
      setState(() {
        _groups = value;
      });
    });

    setState(() {
      _isLoading = false;
    });
  }

  Stream? _groups;
  bool _isLoading = false;
  String _name = '';
  String _email = '';
  String _photoUrl = '';

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _groups,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data['groups'] != null) {
            if (snapshot.data['groups'].length != 0) {
              return ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: snapshot.data['groups'].length,
                itemBuilder: (context, index) {
                  int reversedIndex =
                      snapshot.data!['groups'].length - index - 1;
                  return InkWell(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatGroupPage(
                          groupId: getGroupId(
                              snapshot.data['groups'][reversedIndex]),
                          groupName: getGroupName(
                              snapshot.data['groups'][reversedIndex]),
                          userName: _name,
                        ),
                      ),
                    ),
                    child: ChatContainer(
                      groupName:
                          getGroupName(snapshot.data['groups'][reversedIndex]),
                    ),
                  );
                },
              );
            } else {
              return const Center(
                child: Text('No estás en ningún grupo aún'),
              );
            }
          }
        } else {
          return Center(
            child: CircularProgressIndicator(
              color: Theme.of(context).primaryColor,
            ),
          );
        }
        return const Center(
          child: CircularProgressIndicator(
            color: Colors.red,
          ),
        );
      },
    );
  }
}
