import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat/modules/auth/services/database_service.dart';
import 'package:flutter_chat/modules/chat_group/pages/chat_group_info.dart';
import 'package:flutter_chat/widgets/message_container.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatGroupPage extends StatefulWidget {
  const ChatGroupPage({
    Key? key,
    required this.userName,
    required this.groupId,
    required this.groupName,
    required this.userEmail,
    required this.profilePic,
    required this.groupDescription,
  }) : super(key: key);
  final String groupName;
  final String groupId;
  final String userName;
  final String userEmail;
  final String profilePic;
  final String groupDescription;

  @override
  State<ChatGroupPage> createState() => _ChatGroupPageState();
}

class _ChatGroupPageState extends State<ChatGroupPage> {
  @override
  void didChangeDependencies() async {
    final prefs = await SharedPreferences.getInstance();
    _name = prefs.getString('name')!;
    super.didChangeDependencies();
  }

  Stream? _messages;
  String _admin = '';
  List _groupMembers = [];
  final _messageController = TextEditingController();
  bool _isLoading = false;
  String _name = '';

  @override
  void initState() {
    getChatData();

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
        _name,
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
                      profilePic: widget.profilePic,
                      groupDescription: widget.groupDescription,
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
                    child: Column(
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.8,
                          child: Container(
                            color: const Color.fromARGB(255, 68, 18, 161),
                            child: ListView.builder(
                              reverse: true,
                              primary: true,
                              shrinkWrap: true,
                              itemCount: snapshot.data!['messages'].length,
                              itemBuilder: (context, index) {
                                final reversedIndex =
                                    snapshot.data!['messages'].length -
                                        index -
                                        1;
                                final Timestamp timeStamp = snapshot
                                    .data!['messages'][reversedIndex]['time'];
                                final date =
                                    DateTime.fromMillisecondsSinceEpoch(
                                            timeStamp.seconds * 1000)
                                        .toLocal();
                                final String formattedDate =
                                    "${date.day}/${date.month}/${date.year}";
                                final String formattedTime =
                                    "${date.hour}:${date.minute}";
                                return MessageContainer(
                                  userName: widget.userName,
                                  sender: snapshot.data!['messages']
                                      [reversedIndex]['sender'],
                                  senderEmail: snapshot.data!['messages']
                                          [reversedIndex]['senderEmail'] ??
                                      '',
                                  message: snapshot.data!['messages']
                                      [reversedIndex]['message'],
                                  time: formattedTime,
                                  date: formattedDate,
                                  isGroup: true,
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
                                  maxLines: null,
                                  keyboardType: TextInputType.multiline,
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
