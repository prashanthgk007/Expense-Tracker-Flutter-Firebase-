import 'package:expense_tracker_app/Bloc/Authentication/auth_bloc.dart';
import 'package:expense_tracker_app/Bloc/Authentication/auth_event.dart';
import 'package:expense_tracker_app/Bloc/Authentication/auth_state.dart';
import 'package:expense_tracker_app/Bloc/Users/user_bloc.dart';
import 'package:expense_tracker_app/Bloc/Users/user_event.dart';
import 'package:expense_tracker_app/Bloc/Users/user_state.dart';
import 'package:expense_tracker_app/Helper/router.dart';
import 'package:expense_tracker_app/Model/userModel.dart';
import 'package:expense_tracker_app/Helper/utilities.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  bool isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    context.read<UserBloc>().add(GetUserProfileEvent());
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Settings", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),

      body: BlocConsumer<UserBloc, UserState>(
        listener: (context, state) {
          if (state is UserUpdating) {
            AppUtils.showLoading("Updating...");
          } else {
            AppUtils.dismiss();
          }

          if (state is UserUpdateSuccess) {
            AppUtils.showSuccess("Profile Updated");
            context.read<UserBloc>().add(GetUserProfileEvent());
          }

          if (state is UserFailure) {
            AppUtils.showError(state.error);
          }
        },

        builder: (context, state) {
          if (state is UserLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is! UserLoaded) {
            return const SizedBox();
          }

          final user = state.user;
          final displayName =
              user.username.isNotEmpty ? user.username : "No Name";
          final displayEmail =
              user.email.isNotEmpty ? user.email : "Unknown Email";

          return Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                /// PROFILE CARD
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.blue.shade600,
                        child: Text(
                          displayName[0].toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              displayName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              displayEmail,
                              style: TextStyle(color: Colors.grey.shade700),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "••••••••",
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                letterSpacing: 2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.grey.shade700),
                        onPressed: () => _showEditDialog(context, user),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                /// LOGOUT
                BlocConsumer<AuthBloc, AuthState>(
                  listener: (context, state) {
                    if (state is AuthSuccess) {
                      AppUtils.showSuccess("Logged Out");
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        AppRoutes.login,
                        (_) => false,
                      );
                    }

                    if (state is AuthFailure) {
                      AppUtils.showError(state.error);
                    }
                  },
                  builder: (context, state) {
                    return GestureDetector(
                      onTap: state is AuthLoading
                          ? null
                          : () => context
                              .read<AuthBloc>()
                              .add(AuthLogoutEvent()),
                      child: Container(
                        height: 55,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: LinearGradient(
                            colors: [
                              Colors.red.shade600,
                              Colors.red.shade400,
                            ],
                          ),
                        ),
                        child: Center(
                          child: state is AuthLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text(
                                  "Logout",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// EDIT PROFILE DIALOG
  void _showEditDialog(BuildContext context, UserModel user) {
    nameCtrl.text = user.username;
    emailCtrl.text = user.email;
    passwordCtrl.clear();

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text("Edit Profile"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Name")),
              const SizedBox(height: 10),
              TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: "Email")),
              const SizedBox(height: 10),
              TextField(
                key: ValueKey(isPasswordVisible),
                controller: passwordCtrl,
                obscureText: !isPasswordVisible,
                decoration: InputDecoration(
                  labelText: "New Password",
                  suffixIcon: IconButton(
                    icon: Icon(
                      isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () => setState(() {
                      isPasswordVisible = !isPasswordVisible;
                    }),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                this.context.read<UserBloc>().add(
                      UpdateUserProfileEvent(
                        name: nameCtrl.text.trim(),
                        email: emailCtrl.text.trim(),
                        password: passwordCtrl.text.trim().isEmpty
                            ? null
                            : passwordCtrl.text.trim(),
                      ),
                    );
              },
              child: const Text("Update"),
            ),
          ],
        ),
      ),
    );
  }
}
