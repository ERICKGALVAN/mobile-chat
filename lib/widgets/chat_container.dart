import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
  }) : super(key: key);
  final String groupName;
  final String? message;
  final String? subtitle;
  final bool? isJoined;
  final String lastSenderEmail;
  final String lastSenderName;
  final bool isGroup;

  @override
  Widget build(BuildContext context) {
    final String userEmail = FirebaseAuth.instance.currentUser!.email!;
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
            const CircleAvatar(),
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
                  message != null
                      ? Row(
                          children: [
                            lastSenderEmail.isEmpty || lastSenderName.isEmpty
                                ? Container()
                                : Text(
                                    userEmail == lastSenderEmail
                                        ? 'You'
                                        : '$lastSenderName:',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                            const SizedBox(width: 5),
                            Text(
                              message!,
                              style: const TextStyle(
                                overflow: TextOverflow.ellipsis,
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
