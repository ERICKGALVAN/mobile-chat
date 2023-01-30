import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat/modules/home/pages/home_page.dart';
import 'package:flutter_chat/widgets/main_button.dart';

import '../../auth/services/database_service.dart';

class ChatInfo extends StatefulWidget {
  const ChatInfo({
    Key? key,
    required this.admin,
    required this.userName,
    required this.groupMembers,
    required this.groupId,
    required this.groupName,
  }) : super(key: key);
  final String userName;
  final String groupName;
  final String groupId;
  final String admin;
  final List groupMembers;

  @override
  State<ChatInfo> createState() => _ChatInfoState();
}

class _ChatInfoState extends State<ChatInfo> {
  bool _isLoading = false;
  String getName(String value) {
    return value.split('_')[1];
  }

  Future<void> _leaveGroup() async {
    setState(() {
      _isLoading = true;
    });
    await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
        .toggleJoinGroup(
      widget.groupId,
      widget.userName,
      widget.groupName,
    )
        .then((value) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Has salido del grupo'),
        ),
      );
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const HomePage(),
        ),
      );
    }).catchError((e) {
      setState(() {
        _isLoading = false;
      });
      log(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ha ocurrido un error'),
        ),
      );
    });
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${widget.groupMembers.length.toString()} miembros',
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 18,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromARGB(255, 236, 236, 236)
                          .withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: widget.groupMembers.length,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    bool isAdmin = widget.groupMembers[index] == widget.admin;
                    return ListTile(
                      title: Text(
                        getName(widget.groupMembers[index]),
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: isAdmin
                              ? Theme.of(context).primaryColor
                              : Colors.black,
                        ),
                        textAlign: TextAlign.start,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              MainButton(
                text: 'Salir del grupo',
                onPressed: () async {
                  await _leaveGroup();
                },
                backgroundColor: const Color.fromARGB(255, 226, 26, 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
