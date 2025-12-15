import 'package:expense_tracker_app/Model/userModel.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'user_event.dart';
import 'user_state.dart';
import '../../Services/auth_service.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final AuthService _service = AuthService();

  UserBloc() : super(UserInitial()) {
    // Get user profile
    on<GetUserProfileEvent>((event, emit) async {
      emit(UserLoading());
      try {
        final userData = await _service.getUserProfile(); // Map
        final user = UserModel.fromMap(userData); // Convert to model
        emit(UserLoaded(user));
      } catch (e) {
        emit(UserFailure(e.toString()));
      }
    });

    // Update user profile
    on<UpdateUserProfileEvent>((event, emit) async {
      emit(UserUpdating());

      try {
        final updatedUser = await _service.updateUserProfile(
          name: event.name,
          email: event.email,
          password: event.password,
        );

        if (updatedUser != null) {
          emit(UserUpdateSuccess());
        } else {
          emit(UserFailure("Failed to update user."));
        }
      } catch (e) {
        emit(UserFailure(e.toString()));
      }
    });
  }
}
