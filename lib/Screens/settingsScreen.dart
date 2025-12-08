import 'package:expense_tracker_app/Bloc/Authentication/auth_bloc.dart';
import 'package:expense_tracker_app/Bloc/Authentication/auth_event.dart';
import 'package:expense_tracker_app/Bloc/Authentication/auth_state.dart';
import 'package:expense_tracker_app/Bloc/Users/user_bloc.dart';
import 'package:expense_tracker_app/Bloc/Users/user_event.dart';
import 'package:expense_tracker_app/Bloc/Users/user_state.dart';
import 'package:expense_tracker_app/Model/userModel.dart';
import 'package:expense_tracker_app/Helper/router.dart';
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

  @override
  void initState() {
    super.initState();
    context.read<UserBloc>().add(GetUserProfileEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0c1324),
      appBar: AppBar(
        title: const Text("Settings", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: BlocConsumer<UserBloc, UserState>(
        listener: (context, state) {
          if (state is UserUpdated) {
            AppUtils.showSuccess(state.message);
          }
          if (state is UserFailure) {
            AppUtils.showError(state.error);
          }
        },
        builder: (context, state) {
          if (state is UserLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          UserModel? user;
          if (state is UserLoaded) user = state.user;
          if (state is UserUpdated) user = state.user;

          String displayName = user?.username.isNotEmpty == true ? user!.username : "No Name";
          String displayEmail = user?.email.isNotEmpty == true ? user!.email : "Unknown Email";
          String avatarLetter = displayName.isNotEmpty ? displayName[0].toUpperCase() : "?";

          return Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              children: [
                // PROFILE CARD
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xff1A2238),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: const Color(0xff6A5AE0),
                        child: Text(
                          avatarLetter,
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
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              displayEmail,
                              style: const TextStyle(color: Colors.white54),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "••••••••", // masked password hint
                              style: const TextStyle(
                                color: Colors.white38,
                                letterSpacing: 2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.white70),
                        onPressed: () => _showEditDialog(context, user),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // LOGOUT BUTTON
                BlocConsumer<AuthBloc, AuthState>(
                  listener: (context, state) {
                    if (state is AuthSuccess) {
                      AppUtils.showSuccess("Logged Out");
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        AppRoutes.login,
                        (route) => false,
                      );
                    } else if (state is AuthFailure) {
                      AppUtils.showError(state.error);
                    }
                  },
                  builder: (context, state) {
                    return GestureDetector(
                      onTap: () => context.read<AuthBloc>().add(AuthLogoutEvent()),
                      child: Container(
                        height: 55,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: const LinearGradient(
                            colors: [Color(0xffFF5757), Color(0xffFF7979)],
                          ),
                        ),
                        child: Center(
                          child: state is AuthLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text(
                                  "Logout",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 18,
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

  void _showEditDialog(BuildContext context, UserModel? user) {
    if (user == null) return;
    bool isPasswordVisible = false;

    nameCtrl.text = user.username ?? "";
    emailCtrl.text = user.email ?? "";
    passwordCtrl.clear();

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: const Color(0xff1A2238),
          title: const Text("Edit Profile", style: TextStyle(color: Colors.white)),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: "Name",
                    labelStyle: TextStyle(color: Colors.white70),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: emailCtrl,
                  decoration: const InputDecoration(
                    labelText: "Email",
                    labelStyle: TextStyle(color: Colors.white70),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: passwordCtrl,
                  obscureText: !isPasswordVisible,
                  decoration: InputDecoration(
                    labelText: "Password",
                    labelStyle: const TextStyle(color: Colors.white70),
                    hintText: "Enter new password",
                    hintStyle: const TextStyle(color: Colors.white38),
                    suffixIcon: IconButton(
                      icon: Icon(
                        isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                        color: Colors.white70,
                      ),
                      onPressed: () {
                        setState(() {
                          isPasswordVisible = !isPasswordVisible;
                        });
                      },
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text("Cancel", style: TextStyle(color: Colors.white70)),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: const Text("Update"),
              onPressed: () {
                context.read<UserBloc>().add(
                      UpdateUserProfileEvent(
                        name: nameCtrl.text.trim(),
                        email: emailCtrl.text.trim(),
                        password: passwordCtrl.text.trim().isEmpty ? null : passwordCtrl.text.trim(),
                      ),
                    );
              },
            ),
          ],
        ),
      ),
    );
  }
}
