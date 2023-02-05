import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';

import '../../../auth/services/database_service.dart';

part 'groups_state.dart';

class GroupsCubit extends Cubit<GroupsState> {
  GroupsCubit() : super(GroupsInitial()) {
    getUserGroups();
  }

  Stream? groups;

  Future<void> getUserGroups() async {
    emit(LoadingGroups(true));
    groups = await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
        .getUserGroups();
    emit(LoadedGroups(groups!));
  }
}
