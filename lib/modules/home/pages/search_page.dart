import 'package:flutter/material.dart';
import 'package:flutter_chat/modules/chat/pages/chat_info.dart';
import 'package:flutter_chat/widgets/chat_container.dart';

import '../../auth/services/database_service.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({
    Key? key,
    required this.userName,
  }) : super(key: key);
  final String userName;

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _textController = TextEditingController();
  bool _isLoading = false;
  final List _users = [];
  final List _groups = [];
  List _isJoined = [];

  Future<void> _search() async {
    if (_textController.text.isNotEmpty) {
      _users.clear();
      _groups.clear();
      _isJoined.clear();
      setState(() {
        _isLoading = true;
      });
      await DatabaseService().searchUserByName(_textController.text).then(
        (value) {
          if (value.docs.isNotEmpty) {
            _users.addAll(value.docs);
          }
        },
      );
      await DatabaseService().searchGroup(_textController.text).then(
        (value) {
          if (value.docs.isNotEmpty) {
            _groups.addAll(value.docs);
          }
        },
      );
      await DatabaseService().searchUserByEmail(_textController.text).then(
        (value) {
          if (value.docs.isNotEmpty) {
            _users.addAll(value.docs);
          }
        },
      );

      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        title: Row(
          children: [
            Expanded(
              child: TextField(
                onChanged: (value) {
                  _users.clear();
                  _groups.clear();
                  _isJoined.clear();
                },
                controller: _textController,
                style: const TextStyle(
                  color: Colors.white,
                ),
                decoration: const InputDecoration(
                  hintText: 'Buscar',
                  hintStyle: TextStyle(
                    color: Colors.white,
                  ),
                  border: InputBorder.none,
                ),
                keyboardType: TextInputType.emailAddress,
              ),
            ),
            IconButton(
              onPressed: () {
                if (_textController.text.isNotEmpty) {
                  _search();
                }
              },
              icon: const Icon(
                Icons.search,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _isLoading
                ? LinearProgressIndicator(
                    color: Theme.of(context).primaryColor,
                    backgroundColor:
                        Theme.of(context).primaryColor.withOpacity(0.2),
                  )
                : Container(),
            ListView.builder(
              itemBuilder: (context, index) {
                return _users[index]['uid'] != widget.userName
                    ? InkWell(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatInfo(
                              contactName: _users[index]['name'],
                              contactId: _users[index]['uid'],
                              userId: widget.userName,
                            ),
                          ),
                        ),
                        child: ChatContainer(
                          groupName: _users[index]['name'],
                          message: _users[index]['email'],
                        ),
                      )
                    : Container();
              },
              itemCount: _users.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
            ),
            ListView.builder(
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () {},
                  child: ChatContainer(
                    groupName: _groups[index]['groupName'],
                    message: _groups[index]['groupDescription'],
                    subtitle: '${_groups[index]['members'].length} miembros',
                  ),
                );
              },
              itemCount: _groups.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
            ),
          ],
        ),
      ),
    );
  }
}
