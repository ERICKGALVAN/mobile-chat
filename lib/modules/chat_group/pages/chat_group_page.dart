import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat/modules/auth/services/database_service.dart';
import 'package:flutter_chat/modules/chat_group/pages/chat_group_info.dart';

class ChatGroupPage extends StatefulWidget {
  const ChatGroupPage({
    Key? key,
    required this.userName,
    required this.groupId,
    required this.groupName,
  }) : super(key: key);
  final String groupName;
  final String groupId;
  final String userName;

  @override
  State<ChatGroupPage> createState() => _ChatGroupPageState();
}

class _ChatGroupPageState extends State<ChatGroupPage> {
  Stream<QuerySnapshot>? _chats;
  String _admin = '';
  List _groupMembers = [];

  @override
  void initState() {
    getChatData();
    super.initState();
  }

  Future getChatData() async {
    await DatabaseService().getMessages(widget.groupId).then((value) {
      setState(() {
        _chats = value;
      });
    });
    await DatabaseService().getGroupAdmin(widget.groupId).then((value) {
      setState(() {
        _admin = value;
      });
    });
    await DatabaseService().getGroupMembers(widget.groupId).then((value) {
      setState(() {
        _groupMembers = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(widget.groupName),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return ChatGroupInfo(
                      admin: _admin,
                      userName: widget.userName,
                      groupId: widget.groupId,
                      groupMembers: _groupMembers,
                      groupName: widget.groupName,
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
        child: Text(widget.groupName),
      ),
    );
  }
}
