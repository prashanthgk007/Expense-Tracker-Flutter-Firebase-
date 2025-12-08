import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_tracker_app/Bloc/Authentication/auth_bloc.dart';
import 'package:expense_tracker_app/Bloc/Authentication/auth_event.dart';
import 'package:expense_tracker_app/Bloc/Authentication/auth_state.dart';
import 'package:expense_tracker_app/Helper/router.dart';
import 'package:expense_tracker_app/Helper/utilities.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
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
          if (state is AuthSuccess) {
            AppUtils.showSuccess("Login Successful!");
            Navigator.pushReplacementNamed(context, AppRoutes.home);
          } else if (state is AuthFailure) {
            AppUtils.showError(state.error);
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
              child: Form(
                key: _formKey,
                autovalidateMode: 
                    _autoValidate ? AutovalidateMode.always : AutovalidateMode.disabled,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      "Welcome Back 👋",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Login to continue",
                      style: TextStyle(color: Colors.white54),
                    ),
                    const SizedBox(height: 45),

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

                    // Login Button
                    state is AuthLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : GestureDetector(
                            onTap: () {
                              if (_formKey.currentState!.validate()) {
                                context.read<AuthBloc>().add(
                                      AuthLoginEvent(
                                        emailCtrl.text.trim(),
                                        passCtrl.text.trim(),
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
                                  "Login",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),
                          ),

                    const SizedBox(height: 15),

                    TextButton(
                      onPressed: () => Navigator.pushNamed(
                          context, AppRoutes.forgotPassword),
                      child: const Text("Forgot Password?"),
                    ),

                    const SizedBox(height: 10),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Don't have an account?",
                          style: TextStyle(color: Colors.white54),
                        ),
                        TextButton(
                          onPressed: () =>
                              Navigator.pushNamed(context, AppRoutes.signup),
                          child: const Text(
                            "Sign Up",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        )
                      ],
                    ),
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
                      color: Colors.white54),
                  onPressed: togglePassword,
                )
              : null,
        ),
      ),
    );
  }
}
