import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_chat/modules/auth/services/database_service.dart';

class MessageContainer extends StatelessWidget {
  const MessageContainer({
    Key? key,
    required this.userName,
    required this.sender,
    required this.senderEmail,
    required this.message,
    required this.time,
    required this.date,
    required this.isGroup,
  }) : super(key: key);

  final String userName;
  final String sender;
  final String senderEmail;
  final String message;
  final String time;
  final String date;
  final bool isGroup;

  @override
  Widget build(BuildContext context) {
    final String todayDate =
        '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}';
    return Container(
      padding: const EdgeInsets.only(
        top: 8,
        bottom: 8,
        left: 14,
        right: 14,
      ),
      child: Align(
        alignment:
            (sender == userName ? Alignment.topRight : Alignment.topLeft),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: (sender == userName
                ? Theme.of(context).primaryColor.withOpacity(0.8)
                : const Color(0xff1A1A1A)),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isGroup && sender != userName)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      sender,
                      style: const TextStyle(
                        fontSize: 17,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 5),
                    const Text(
                      '|',
                      style: TextStyle(
                        fontSize: 17,
                        color: Colors.white,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      senderEmail,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.white,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 5),
              SelectableText(
                DatabaseService().decryptText(message),
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 5),
              date != todayDate
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          date,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.white,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          time,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.white,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ],
                    )
                  : Text(
                      time,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.white,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
