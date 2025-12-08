import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_tracker_app/Bloc/Authentication/auth_bloc.dart';
import 'package:expense_tracker_app/Bloc/Authentication/auth_event.dart';
import 'package:expense_tracker_app/Bloc/Authentication/auth_state.dart';
import 'package:expense_tracker_app/Helper/utilities.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController passCtrl = TextEditingController();

  bool _obscurePassword = true;
  bool _autoValidate = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0c1324),

      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthLoading) {
            AppUtils.showLoading("Creating account...");
          }

          if (state is AuthSuccess) {
            AppUtils.showSuccess("Signup Successful!");
            Navigator.pop(context);
          }

          if (state is AuthFailure) {
            AppUtils.showError(state.error);
          }
        },

        builder: (context, state) {
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
              child: Form(
                key: _formKey,
                autovalidateMode: _autoValidate
                    ? AutovalidateMode.always
                    : AutovalidateMode.disabled,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      "Create Account ✨",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),
                    const Text(
                      "Fill the details to get started",
                      style: TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 40),

                    // Name Field
                    _inputField(
                      controller: nameCtrl,
                      label: "Full Name",
                      icon: Icons.person,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Name is required";
                        }
                        if (value.length < 3) {
                          return "Name must be at least 3 characters";
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Email Field
                    _inputField(
                      controller: emailCtrl,
                      label: "Email",
                      icon: Icons.email,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Email is required";
                        }
                        if (!RegExp(r"^[^\s@]+@[^\s@]+\.[^\s@]+$")
                            .hasMatch(value)) {
                          return "Enter a valid email";
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Password Field
                    _inputField(
                      controller: passCtrl,
                      label: "Password",
                      icon: Icons.lock,
                      isPassword: true,
                      obscure: _obscurePassword,
                      togglePassword: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Password is required";
                        }
                        if (value.length < 6) {
                          return "Password must be at least 6 characters";
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 30),

                    // Submit Button
                    state is AuthLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : GestureDetector(
                            onTap: () {
                              if (_formKey.currentState!.validate()) {
                                context.read<AuthBloc>().add(
                                      AuthSignupEvent(
                                        emailCtrl.text.trim(),
                                        passCtrl.text.trim(),
                                        nameCtrl.text.trim(),
                                      ),
                                    );
                              } else {
                                setState(() => _autoValidate = true);
                              }
                            },
                            child: Container(
                              height: 55,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xff6A5AE0),
                                    Color(0xff7F8CFF)
                                  ],
                                ),
                              ),
                              child: const Center(
                                child: Text(
                                  "Sign Up",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),
                          ),

                    const SizedBox(height: 20),

                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        "Already have an account? Login",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Reusable Input Widget
  Widget _inputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?) validator,
    bool isPassword = false,
    bool obscure = false,
    VoidCallback? togglePassword,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: const Color(0xff1A2238),
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextFormField(
        controller: controller,
        validator: validator,
        obscureText: isPassword ? obscure : false,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          border: InputBorder.none,
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white54),
          prefixIcon: Icon(icon, color: Colors.white38),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    obscure ? Icons.visibility : Icons.visibility_off,
                    color: Colors.white54,
                  ),
                  onPressed: togglePassword,
                )
              : null,
        ),
      ),
    );
  }
}
