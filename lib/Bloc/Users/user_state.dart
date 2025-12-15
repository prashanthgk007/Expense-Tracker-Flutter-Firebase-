import '../../Model/userModel.dart';

abstract class UserState {}

class UserInitial extends UserState {}

class UserLoading extends UserState {}

class UserUpdating extends UserState {}

class UserLoaded extends UserState {
  final UserModel user;
  UserLoaded(this.user);
}

class UserUpdateSuccess extends UserState {}

class UserSuccess extends UserState {
  final String message;
  UserSuccess(this.message);
}

class UserFailure extends UserState {
  final String error;
  UserFailure(this.error);
}
