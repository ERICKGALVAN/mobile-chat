import 'package:flutter/material.dart';

class ChatContainer extends StatelessWidget {
  const ChatContainer({
    Key? key,
    required this.groupName,
    this.message,
    this.subtitle,
    this.isJoined,
  }) : super(key: key);
  final String groupName;
  final String? message;
  final String? subtitle;
  final bool? isJoined;

  @override
  Widget build(BuildContext context) {
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
                      ? Text(
                          message!,
                          style: const TextStyle(
                            overflow: TextOverflow.ellipsis,
                          ),
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
