part of 'groups_cubit.dart';

abstract class GroupsState {}

class GroupsInitial extends GroupsState {
  Stream? get props => null;
}

class LoadingGroups extends GroupsState {
  LoadingGroups(this.isLoading);
  bool isLoading;
  bool get props => isLoading;
}

class LoadedGroups extends GroupsState {
  LoadedGroups(this.groups);
  Stream groups;
  Stream get props => groups;
}

class ErrorGroups extends GroupsState {
  ErrorGroups(this.error);
  String error;
  String get props => error;
}
