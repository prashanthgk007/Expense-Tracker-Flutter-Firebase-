abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {}

class AuthFailure extends AuthState {
  final String error;
  AuthFailure(this.error);
}

class ResetPasswordSuccess extends AuthState {}

class ResetPasswordFailure extends AuthState {
    final String error;
  ResetPasswordFailure(this.error);
}