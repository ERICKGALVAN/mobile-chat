part of 'contacts_cubit.dart';

abstract class ContactsState {}

class ContactsInitial extends ContactsState {
  Stream? get props => null;
  Map get namesProps => {};
  Map get emailsProps => {};
}

class LoadingState extends ContactsState {
  LoadingState(this.isLoading);
  bool isLoading;
  bool get props => isLoading;
}

class LoadedState extends ContactsState {
  LoadedState(
    this.contacts,
    this.names,
    this.emails,
  );
  Stream contacts;
  Map names;
  Map emails;
  Stream get props => contacts;
  Map get namesProps => names;
  Map get emailsProps => emails;
}

class ErrorState extends ContactsState {
  ErrorState(this.error);
  String error;
  String get props => error;
}
