import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat/modules/auth/services/database_service.dart';

class ChatContainer extends StatelessWidget {
  const ChatContainer({
    Key? key,
    required this.groupName,
    this.message,
    this.subtitle,
    this.isJoined,
    required this.lastSenderEmail,
    required this.lastSenderName,
    required this.isGroup,
    required this.isTyping,
    required this.photoUrl,
    required this.showUserName,
    this.lastMessageHour,
    this.lastMessageDate,
  }) : super(key: key);
  final String groupName;
  final String? message;
  final String? subtitle;
  final bool? isJoined;
  final String lastSenderEmail;
  final String lastSenderName;
  final bool isGroup;
  final bool isTyping;
  final String photoUrl;
  final bool showUserName;
  final String? lastMessageHour;
  final String? lastMessageDate;

  @override
  Widget build(BuildContext context) {
    final String userEmail = FirebaseAuth.instance.currentUser!.email!;
    final String todayDate =
        '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}';

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey,
            width: 0.5,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage:
                  photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    groupName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 5),
                  isTyping
                      ? Text(
                          'Typing...',
                          style: TextStyle(
                            color:
                                Theme.of(context).primaryColor.withOpacity(0.8),
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : message != null
                          ? Row(
                              children: [
                                lastSenderEmail.isEmpty ||
                                        lastSenderName.isEmpty
                                    ? Container()
                                    : Text(
                                        userEmail == lastSenderEmail
                                            ? 'You'
                                            : showUserName
                                                ? lastSenderName
                                                : '',
                                        style: const TextStyle(
                                          fontSize: 15,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                const SizedBox(width: 5),
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.4,
                                  height: 15,
                                  child: Text(
                                    message!.contains('@')
                                        ? message!
                                        : DatabaseService()
                                            .decryptText(message!),
                                    style: const TextStyle(
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Container(),
                  subtitle != null
                      ? Text(
                          subtitle!,
                          style: const TextStyle(
                            overflow: TextOverflow.ellipsis,
                          ),
                        )
                      : Container(),
                ],
              ),
            ),
            todayDate != lastMessageDate
                ? lastMessageDate != null
                    ? Text(
                        lastMessageDate!,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 15,
                        ),
                      )
                    : Container()
                : lastMessageHour != null
                    ? Text(
                        lastMessageHour!,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 15,
                        ),
                      )
                    : Container(),
            isJoined != null
                ? isJoined!
                    ? const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                      )
                    : const Icon(
                        Icons.add_circle,
                        color: Colors.blue,
                      )
                : Container(),
          ],
        ),
      ),
    );
  }
}
