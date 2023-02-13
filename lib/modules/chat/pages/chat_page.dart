import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../widgets/message_container.dart';
import '../../auth/services/database_service.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({
    Key? key,
    required this.chatId,
    required this.contactName,
    required this.contactId,
  }) : super(key: key);

  final String chatId;
  final String contactName;
  final String contactId;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  @override
  void didChangeDependencies() async {
    final prefs = await SharedPreferences.getInstance();
    _name = prefs.getString('name')!;
    _email = prefs.getString('email')!;
    _messages = await DatabaseService().getChatMessages(widget.chatId);
    setState(() {});
    super.didChangeDependencies();
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      await DatabaseService().sendMessageToChat(
        widget.chatId,
        _messageController.text,
        _name,
        _email,
      );
    }
    _messageController.clear();
  }

  String _name = '';
  String _email = '';
  Stream? _messages;
  final _scrollController = ScrollController();
  final _messageController = TextEditingController();
  bool _isTyping = false;
  bool _firstEnter = false;
  Timer? _timer;

  void _startTimer() {
    _timer = Timer(const Duration(milliseconds: 300), () async {
      await changeIsTyping(false);
      _isTyping = false;
    });
  }

  void _cancelTimer() {
    if (_timer != null) {
      _timer!.cancel();
      _timer = null;
    }
  }

  Future<void> changeIsTyping(bool isTyping) async {
    await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
        .changeIsTyping(widget.chatId, isTyping);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        title: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('messages')
              .doc(widget.chatId)
              .snapshots(),
          builder: (context, snapshot) {
            return Column(
              children: [
                Text(widget.contactName),
                const SizedBox(height: 5),
                snapshot.hasData &&
                        snapshot.data!['${widget.contactId}isTyping']
                    ? const Text(
                        'Typing...',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      )
                    : const SizedBox.shrink(),
              ],
            );
          },
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.info,
            ),
          ),
        ],
      ),
      body: StreamBuilder(
        stream: _messages,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return SingleChildScrollView(
              controller: _scrollController,
              reverse: true,
              child: Column(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.8,
                    child: Container(
                      color: const Color.fromARGB(255, 122, 14, 26),
                      child: ListView.builder(
                        primary: true,
                        shrinkWrap: true,
                        itemCount: snapshot.data!['messages'].length,
                        itemBuilder: (context, index) {
                          final Timestamp timeStamp =
                              snapshot.data!['messages'][index]['time'];
                          final date = DateTime.fromMillisecondsSinceEpoch(
                                  timeStamp.seconds * 1000)
                              .toLocal();
                          final String formattedDate =
                              "${date.day}/${date.month}/${date.year}";
                          final String formattedTime =
                              "${date.hour}:${date.minute}";
                          return MessageContainer(
                            userName: _name,
                            sender: snapshot.data!['messages'][index]['sender'],
                            senderEmail: snapshot.data!['messages'][index]
                                    ['senderEmail'] ??
                                '',
                            message: snapshot.data!['messages'][index]
                                ['message'],
                            date: formattedDate,
                            time: formattedTime,
                            isGroup: false,
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
                            onChanged: (value) async {
                              if (!_firstEnter) {
                                await changeIsTyping(true);
                                _firstEnter = true;
                              }
                              if (!_isTyping) {
                                await changeIsTyping(true);
                              }
                              _cancelTimer();
                              _startTimer();
                            },
                          ),
                        ),
                        SizedBox(
                          height: 50,
                          width: 50,
                          child: FloatingActionButton(
                            onPressed: () async {
                              _sendMessage();
                            },
                            backgroundColor: Theme.of(context).primaryColor,
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
            return Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor,
              ),
            );
          }
        },
      ),
    );
  }
}
