import 'package:badges/badges.dart' as badges;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat/modules/home/pages/chats.dart';
import 'package:flutter_chat/modules/home/pages/create_group.dart';
import 'package:flutter_chat/modules/home/pages/groups.dart';
import 'package:flutter_chat/modules/home/pages/notifications_page.dart';
import 'package:flutter_chat/modules/home/pages/search_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/drawer_home.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _name = '';
  String _email = '';
  String _photoUrl = '';
  bool _isLoading = false;

  @override
  void initState() {
    getUserData();
    super.initState();
  }

  Future<void> getUserData() async {
    setState(() {
      _isLoading = true;
    });
    final prefs = await SharedPreferences.getInstance();
    _name = prefs.getString('name') ?? '';
    _photoUrl = prefs.getString('photoUrl') ?? '';
    _email = prefs.getString('email') ?? '';
    setState(() {
      _isLoading = false;
    });
  }

  String getGroupId(String value) {
    return value.split('_')[0];
  }

  String getGroupName(String value) {
    return value.split('_')[1];
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        drawer: DrawerHome(name: _name, email: _email, photoUrl: _photoUrl),
        appBar: AppBar(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Theme.of(context).primaryColor,
          title: const Text('Home'),
          bottom: const TabBar(
            indicatorColor: Colors.white,
            tabs: [
              Tab(
                text: 'Chats',
              ),
              Tab(
                text: 'Grupos',
              ),
            ],
          ),
          actions: [
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(FirebaseAuth.instance.currentUser!.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting ||
                    !snapshot.hasData ||
                    snapshot.hasError ||
                    snapshot.data!['requestReceived'].length == 0) {
                  return const Icon(
                    Icons.notifications,
                  );
                }
                return badges.Badge(
                  badgeContent: Text(
                    snapshot.data!['requestReceived'].length.toString(),
                    style: const TextStyle(color: Colors.white),
                  ),
                  position: badges.BadgePosition.topEnd(top: 1, end: 5),
                  child: IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NotificationsPage(
                            notifications: snapshot.data!['requestReceived'],
                          ),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.notifications,
                    ),
                  ),
                );
              },
            ),
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateGroup(
                      userName: _name,
                    ),
                  ),
                );
              },
              icon: const Icon(
                Icons.add,
                color: Colors.white,
              ),
            ),
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SearchPage(
                      userName: FirebaseAuth.instance.currentUser!.uid,
                    ),
                  ),
                );
              },
              icon: const Icon(
                Icons.search,
              ),
            ),
          ],
        ),
        body: const TabBarView(
          children: [
            Chats(),
            Groups(),
          ],
        ),
      ),
    );
  }
}
