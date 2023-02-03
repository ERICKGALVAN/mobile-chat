import 'package:flutter/material.dart';
import 'package:flutter_chat/modules/auth/services/database_service.dart';
import 'package:flutter_chat/modules/home/widgets/notification_container.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({
    Key? key,
    required this.notifications,
  }) : super(key: key);
  final List notifications;

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  void didChangeDependencies() async {
    setState(() {
      _isLoading = true;
    });
    for (int i = 0; i < widget.notifications.length; i++) {
      await DatabaseService()
          .findUserById(widget.notifications[i])
          .then((value) {
        setState(() {
          _users.add(value.data());
        });
      });
    }
    setState(() {
      _isLoading = false;
    });
    super.didChangeDependencies();
  }

  final List _users = [];
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notificaciones',
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor,
              ),
            )
          : ListView.builder(
              itemCount: widget.notifications.length,
              itemBuilder: (context, index) {
                return NotificationContainer(
                  userName: _users[index]['name'],
                  email: _users[index]['email'],
                  userId: _users[index]['uid'],
                );
              },
            ),
    );
  }
}
