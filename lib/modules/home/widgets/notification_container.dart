import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat/modules/auth/services/database_service.dart';
import 'package:flutter_chat/modules/home/bloc/cotacts_cubit/contacts_cubit.dart';

class NotificationContainer extends StatefulWidget {
  const NotificationContainer({
    Key? key,
    required this.userName,
    required this.email,
    required this.userId,
    required this.senderName,
    required this.senderEmail,
  }) : super(key: key);
  final String userName;
  final String email;
  final String userId;
  final String senderName;
  final String senderEmail;

  @override
  State<NotificationContainer> createState() => _NotificationContainerState();
}

class _NotificationContainerState extends State<NotificationContainer> {
  Future<void> _acceptFriendRequest() async {
    setState(() {
      _isLoading = true;
    });
    await DatabaseService()
        .acceptRequest(
      widget.userId,
      FirebaseAuth.instance.currentUser!.uid,
      widget.senderName,
      widget.userName,
      widget.senderEmail,
      widget.email,
    )
        .then((value) {
      if (value) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Solicitud aceptada'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al aceptar solicitud'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _rejectFriendRequest() async {
    setState(() {
      _isLoading = true;
    });
    await DatabaseService()
        .rejectRequest(widget.userId, FirebaseAuth.instance.currentUser!.uid)
        .then((value) async {
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      await context.read<ContactsCubit>().getUserData();
      if (value) {
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('Solicitud rechazada'),
            backgroundColor: Colors.orange,
          ),
        );
        if (mounted) {
          Navigator.pop(context);
        }
      } else {
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('Error al rechazar solicitud'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
    setState(() {
      _isLoading = false;
    });
  }

  bool _isLoading = false;

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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Te envió una solicitud de amistad',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                FittedBox(
                  child: Text(
                    widget.userName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                FittedBox(
                  child: Text(
                    widget.email,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color.fromARGB(255, 125, 125, 125),
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            _isLoading
                ? CircularProgressIndicator(
                    color: Theme.of(context).primaryColor,
                  )
                : Row(
                    children: [
                      InkWell(
                        onTap: () async {
                          await _acceptFriendRequest();
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: Colors.grey[200],
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(10.0),
                            child: Icon(
                              Icons.check,
                              color: Colors.green,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      InkWell(
                        onTap: () async {
                          await _rejectFriendRequest();
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: Colors.grey[200],
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(10.0),
                            child: Icon(
                              Icons.close,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}
