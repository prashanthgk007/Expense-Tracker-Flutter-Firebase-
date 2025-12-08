abstract class UserEvent {}

class GetUserProfileEvent extends UserEvent {}

class UpdateUserProfileEvent extends UserEvent {
  final String? name;
  final String? email;
  final String? password;

  UpdateUserProfileEvent({this.name, this.email, this.password});
}
