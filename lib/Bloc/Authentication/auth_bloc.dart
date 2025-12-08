import 'package:bloc/bloc.dart';
import 'package:expense_tracker_app/Bloc/Authentication/auth_event.dart';
import 'package:expense_tracker_app/Bloc/Authentication/auth_state.dart';
import 'package:expense_tracker_app/Services/auth_service.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService service;
  
  AuthBloc(this.service) : super(AuthInitial()) {
    // LOGIN
    on<AuthLoginEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        await service.login(event.email, event.password);
        emit(AuthSuccess());
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });

    on<AuthSignupEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        await service.signup(event.email, event.password, event.userName);
        emit(AuthSuccess());
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });

    // LOGOUT
    on<AuthLogoutEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        await service.logout();
        emit(AuthSuccess());
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });

    // PASSWORD RESET
    on<AuthResetPasswordEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        await service.resetPassword(event.email);
        emit(AuthSuccess());
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });
  }
}
