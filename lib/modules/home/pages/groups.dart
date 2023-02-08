import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat/modules/home/bloc/groups_cubit/groups_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../widgets/chat_container.dart';
import '../../chat_group/pages/chat_group_page.dart';

class Groups extends StatefulWidget {
  const Groups({Key? key}) : super(key: key);

  @override
  State<Groups> createState() => _GroupsState();
}

class _GroupsState extends State<Groups> {
  @override
  void didChangeDependencies() async {
    final prefs = await SharedPreferences.getInstance();
    _name = prefs.getString('name');
    _email = prefs.getString('email');

    super.didChangeDependencies();
  }

  String getGroupId(String value) {
    return value.split('_')[0];
  }

  String getGroupName(String value) {
    return value.split('_')[1];
  }

  String? _name = '';
  String? _email = '';

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GroupsCubit, GroupsState>(
      builder: (context, state) {
        if (state is LoadingGroups) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (state is LoadedGroups) {
          return StreamBuilder(
            stream: state.groups,
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
                              builder: (context) => ChatGroupPage(
                                groupId: getGroupId(
                                    snapshot.data['groups'][reversedIndex]),
                                groupName: getGroupName(
                                    snapshot.data['groups'][reversedIndex]),
                                userName: _name ?? '',
                                userEmail: _email ?? '',
                              ),
                            ),
                          ),
                          child: ChatContainer(
                            photoUrl: '',
                            groupName: getGroupName(
                                snapshot.data['groups'][reversedIndex]),
                            lastSenderEmail: '',
                            lastSenderName: '',
                            isGroup: true,
                            isTyping: false,
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
        } else if (state is ErrorGroups) {
          return Center(
            child: Text(state.error),
          );
        } else {
          return const Center(
            child: Text('Error'),
          );
        }
      },
    );
  }
}
