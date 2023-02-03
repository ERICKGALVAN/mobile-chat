import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat/modules/auth/services/database_service.dart';
import 'package:flutter_chat/modules/chat_group/pages/chat_group_info.dart';

class ChatGroupPage extends StatefulWidget {
  const ChatGroupPage({
    Key? key,
    required this.userName,
    required this.groupId,
    required this.groupName,
    required this.userEmail,
  }) : super(key: key);
  final String groupName;
  final String groupId;
  final String userName;
  final String userEmail;

  @override
  State<ChatGroupPage> createState() => _ChatGroupPageState();
}

class _ChatGroupPageState extends State<ChatGroupPage> {
  Stream? _messages;
  String _admin = '';
  List _groupMembers = [];
  final _messageController = TextEditingController();
  bool _isLoading = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    getChatData();

    _scrollController.addListener(() {
      log(_scrollController.hasClients.toString());
    });

    super.initState();
  }

  Future getChatData() async {
    setState(() {
      _isLoading = true;
    });

    await DatabaseService().getGroupAdmin(widget.groupId).then((value) {
      setState(() {
        _admin = value;
      });
    });
    await DatabaseService().getGroupMembers(widget.groupId).then((value) {
      if (mounted) {
        setState(() {
          _groupMembers = value;
        });
      }
    });

    _messages = await DatabaseService().getGroupMessages(widget.groupId);
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      await DatabaseService().sendMessageToGroup(
        widget.groupId,
        _messageController.text,
        widget.userName,
        widget.userEmail,
      );
      _messageController.clear();
    }
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder(
              stream: _messages,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return SingleChildScrollView(
                    reverse: true,
                    child: Column(
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.8,
                          child: Container(
                            color: Colors.red,
                            child: ListView.builder(
                              dragStartBehavior: DragStartBehavior.down,
                              primary: true,
                              shrinkWrap: true,
                              itemCount: snapshot.data!['messages'].length,
                              itemBuilder: (context, index) {
                                return Container(
                                  padding: const EdgeInsets.only(
                                    top: 8,
                                    bottom: 8,
                                    left: 14,
                                    right: 14,
                                  ),
                                  child: Align(
                                    alignment: (snapshot.data!['messages']
                                                [index]['sender'] ==
                                            widget.userName
                                        ? Alignment.topRight
                                        : Alignment.topLeft),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        color: (snapshot.data!['messages']
                                                    [index]['sender'] ==
                                                widget.userName
                                            ? const Color(0xff007EF4)
                                            : const Color(0xff1A1A1A)),
                                      ),
                                      padding: const EdgeInsets.all(16),
                                      child: Text(
                                        snapshot.data!['messages'][index]
                                            ['message'],
                                        style: const TextStyle(
                                          fontSize: 15,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _messageController,
                                  decoration: const InputDecoration(
                                    hintText: 'Type a message',
                                    hintStyle: TextStyle(
                                      color: Colors.black54,
                                      fontSize: 16,
                                    ),
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 50,
                                width: 50,
                                child: FloatingActionButton(
                                  onPressed: () {
                                    _sendMessage();
                                  },
                                  backgroundColor: const Color(0xff007EF4),
                                  elevation: 0,
                                  child: const Icon(
                                    Icons.send,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            ),
    );
  }
}
