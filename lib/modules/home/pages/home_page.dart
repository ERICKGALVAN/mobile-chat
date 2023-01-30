import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat/modules/auth/services/database_service.dart';
import 'package:flutter_chat/modules/home/pages/create_group.dart';
import 'package:flutter_chat/modules/home/pages/search_page.dart';
import 'package:flutter_chat/widgets/chat_container.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../chat/pages/chat_page.dart';
import '../widgets/drawer_home.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Stream? _groups;
  bool _isLoading = false;
  String _name = '';
  String _email = '';
  String _photoUrl = '';

  @override
  void initState() {
    getUserData();
    super.initState();
  }

  @override
  void didChangeDependencies() async {
    setState(() {
      _isLoading = true;
    });
    final prefs = await SharedPreferences.getInstance();
    _name = prefs.getString('name') ?? '';
    _email = prefs.getString('email') ?? '';
    _photoUrl = prefs.getString('photoUrl') ?? '';
    setState(() {
      _isLoading = false;
    });
    super.didChangeDependencies();
  }

  Future<void> getUserData() async {
    setState(() {
      _isLoading = true;
    });

    await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
        .getUserGroups()
        .then((value) {
      log(value.toString());
      setState(() {
        _groups = value;
      });
    });
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

  Widget gruoupList() {
    return StreamBuilder(
      stream: _groups,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data['groups'] != null) {
            if (snapshot.data['groups'].length != 0) {
              return ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: snapshot.data['groups'].length,
                itemBuilder: (context, index) {
                  int reversedIndex =
                      snapshot.data!['groups'].length - index - 1;
                  return InkWell(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatPage(
                          groupId: getGroupId(
                              snapshot.data['groups'][reversedIndex]),
                          groupName: getGroupName(
                              snapshot.data['groups'][reversedIndex]),
                          userName: _name,
                        ),
                      ),
                    ),
                    child: ChatContainer(
                      groupName:
                          getGroupName(snapshot.data['groups'][reversedIndex]),
                    ),
                  );
                },
              );
            } else {
              return const Center(
                child: Text('No estás en ningún grupo aún'),
              );
            }
          }
        } else {
          return Center(
            child: CircularProgressIndicator(
              color: Theme.of(context).primaryColor,
            ),
          );
        }
        return const Center(
          child: CircularProgressIndicator(
            color: Colors.red,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: DrawerHome(name: _name, email: _email, photoUrl: _photoUrl),
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text('Home'),
        actions: [
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
      body: gruoupList(),
    );
  }
}
