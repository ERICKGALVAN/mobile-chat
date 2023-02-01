import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat/modules/home/bloc/groups_cubit/groups_cubit.dart';

import '../../../widgets/chat_container.dart';
import '../../auth/services/database_service.dart';
import '../../chat_group/pages/chat_group_page.dart';

class Groups extends StatefulWidget {
  const Groups({Key? key}) : super(key: key);

  @override
  State<Groups> createState() => _GroupsState();
}

class _GroupsState extends State<Groups> {
  @override
  void initState() {
    super.initState();
  }

  String getGroupId(String value) {
    return value.split('_')[0];
  }

  String getGroupName(String value) {
    return value.split('_')[1];
  }

  Stream? _groups;
  String _name = '';

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GroupsCubit, GroupsState>(
      builder: (context, state) {
        if (state is LoadingState) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (state is LoadedState) {
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
                                userName: _name,
                              ),
                            ),
                          ),
                          child: ChatContainer(
                            groupName: getGroupName(
                                snapshot.data['groups'][reversedIndex]),
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
        } else if (state is ErrorState) {
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
