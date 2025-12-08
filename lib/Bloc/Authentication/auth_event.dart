abstract class AuthEvent {}

class AuthLoginEvent extends AuthEvent {
  final String email;
  final String password;
  AuthLoginEvent(this.email, this.password);
}

class AuthSignupEvent extends AuthEvent {
  final String email;
  final String password;
  final String userName;
  AuthSignupEvent(this.email, this.password, this.userName);
}

class AuthLogoutEvent extends AuthEvent {}

class AuthResetPasswordEvent extends AuthEvent {
  final String email;
  AuthResetPasswordEvent(this.email);
}
