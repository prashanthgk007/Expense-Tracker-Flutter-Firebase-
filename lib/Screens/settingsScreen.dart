// -------------------------------------------
// SETTINGS SCREEN
// -------------------------------------------
import 'package:expense_tracker_app/Bloc/Authentication/auth_bloc.dart';
import 'package:expense_tracker_app/Bloc/Authentication/auth_event.dart';
import 'package:expense_tracker_app/Bloc/Authentication/auth_state.dart';
import 'package:expense_tracker_app/Helper/router.dart';
import 'package:expense_tracker_app/Helper/utilities.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),

      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            AppUtils.showSuccess("Logged out");
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.login,
              (route) => false,
            );
          }

          if (state is AuthFailure) {
            AppUtils.showError(state.error);
          }
        },

        builder: (context, state) {
          return ListView(
            children: [
              ListTile(
                title: const Text("Dark Mode"),
                trailing: Switch(value: false, onChanged: (_) {}),
              ),

              ListTile(
                title: const Text("Logout"),
                trailing: state is AuthLoading 
                  ? const CircularProgressIndicator()
                  : const Icon(Icons.logout),
                onTap: () {
                  context.read<AuthBloc>().add(AuthLogoutEvent());
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
