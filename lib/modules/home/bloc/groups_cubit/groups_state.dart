part of 'groups_cubit.dart';

abstract class GroupsState {}

class GroupsInitial extends GroupsState {
  Stream? get props => null;
}

class LoadingState extends GroupsState {
  LoadingState(this.isLoading);
  bool isLoading;
  bool get props => isLoading;
}

class LoadedState extends GroupsState {
  LoadedState(this.groups);
  Stream groups;
  Stream get props => groups;
}

class ErrorState extends GroupsState {
  ErrorState(this.error);
  String error;
  String get props => error;
}
