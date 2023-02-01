import 'dart:developer';

import 'package:badges/badges.dart' as badges;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat/modules/auth/services/database_service.dart';
import 'package:flutter_chat/modules/home/pages/contacts.dart';
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
  QuerySnapshot? _requestReceived;
  bool _isLoading = false;
  String _name = '';
  String _email = '';
  String _photoUrl = '';

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

  Future getNotifications() async {
    final querySnapshot =
        await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
            .getUserData(_email);
    return querySnapshot;
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
                text: 'Grupos',
              ),
              Tab(
                text: 'Chats',
              ),
            ],
          ),
          actions: [
            FutureBuilder(
              future: getNotifications(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return snapshot.data.docs[0]['requestReceived'].length == 0
                      ? const Icon(
                          Icons.notifications,
                        )
                      : badges.Badge(
                          badgeContent: Text(
                            snapshot.data.docs[0]['requestReceived'].length
                                .toString(),
                            style: const TextStyle(color: Colors.white),
                          ),
                          position: badges.BadgePosition.topEnd(top: 1, end: 5),
                          child: IconButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => NotificationsPage(
                                    notifications: snapshot.data.docs[0]
                                        ['requestReceived'],
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons.notifications,
                            ),
                          ),
                        );
                } else {
                  return const SizedBox();
                }
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
            Groups(),
            Contacts(),
          ],
        ),
      ),
    );
  }
}
