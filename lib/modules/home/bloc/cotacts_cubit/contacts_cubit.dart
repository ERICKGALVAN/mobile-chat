import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../auth/services/database_service.dart';

part 'contacts_state.dart';

class ContactsCubit extends Cubit<ContactsState> {
  ContactsCubit() : super(ContactsInitial()) {
    getUserData();
  }

  Stream? friends;
  Map names = {};
  Map emails = {};

  Future<void> getUserData() async {
    try {
      emit(LoadingState(true));
      friends =
          await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
              .getUserFriends();
      final friendsList = await friends!.first;
      List<Future> futures = [];
      await friendsList['friends'].forEach(
        (element) {
          futures.add(
            DatabaseService().findUserById(element.toString()).then(
              (value) {
                names[element.toString()] = value['name'];
                emails[element.toString()] = value['email'];
              },
            ),
          );
        },
      );
      await Future.wait(futures);
      emit(LoadedState(friends!, names, emails));
    } catch (e) {
      log(e.toString());
      emit(ErrorState(e.toString()));
    }
  }
}
