import '../../Model/userModel.dart';

abstract class UserState {}

class UserInitial extends UserState {}

class UserLoading extends UserState {}

class UserLoaded extends UserState {
  final UserModel user;
  UserLoaded(this.user);
}

class UserUpdated extends UserState {
  final UserModel user;
  final String message;
  UserUpdated({required this.user, required this.message});
}

class UserSuccess extends UserState {
  final String message;
  UserSuccess(this.message);
}

class UserFailure extends UserState {
  final String error;
  UserFailure(this.error);
}
