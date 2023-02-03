import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat/modules/chat/pages/chat_page.dart';

import '../../../widgets/chat_container.dart';
import '../bloc/cotacts_cubit/contacts_cubit.dart';

class Contacts extends StatefulWidget {
  const Contacts({
    Key? key,
  }) : super(key: key);

  @override
  State<Contacts> createState() => _ContactsState();
}

class _ContactsState extends State<Contacts> {
  String getGroupId(String value) {
    return value.split('_')[0];
  }

  String getGroupName(String value) {
    return value.split('_')[1];
  }

  Future getNames(String uid) async {
    final contactsBloc = BlocProvider.of<ContactsCubit>(context);
    if (contactsBloc.state is LoadedState) {
      if (contactsBloc.friends == null) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ContactsCubit, ContactsState>(
      builder: (context, state) {
        if (state is LoadingState) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (state is LoadedState) {
          return StreamBuilder(
            stream: state.contacts,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return state.names.isEmpty
                    ? const Center(
                        child: Text(
                          'No tienes contactos aún',
                        ),
                      )
                    : ListView.builder(
                        itemCount: snapshot.data!['friends'].length,
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChatPage(
                                    userName: '',
                                    contactName: state.names[snapshot
                                        .data!['friends'][index]
                                        .toString()],
                                  ),
                                ),
                              );
                            },
                            child: ChatContainer(
                              groupName: state.names[
                                  snapshot.data!['friends'][index].toString()],
                              message: state.emails[
                                  snapshot.data!['friends'][index].toString()],
                            ),
                          );
                        },
                      );
              } else {
                return const Center(
                  child: Center(
                    child: CircularProgressIndicator(
                      color: Colors.red,
                    ),
                  ),
                );
              }
            },
          );
        }
        return const Center(
          child: Text('Error'),
        );
      },
    );
  }
}
