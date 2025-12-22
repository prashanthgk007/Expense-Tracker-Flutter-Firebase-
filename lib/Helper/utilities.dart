import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class AppUtils {
  // ---------------------------------------------------
  // ✔ EASY LOADING HELPERS
  // ---------------------------------------------------
  static void showLoading([String message = "Loading..."]) {
    EasyLoading.show(status: message);
  }

  static void showSuccess(String message) {
    EasyLoading.showSuccess(message);
  }

  static void showError(String message) {
    EasyLoading.showError(message);
  }

  static void dismiss() {
    EasyLoading.dismiss();
  }

  static void showInfo(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Colors.blueAccent,
    ),
  );
}


  // ---------------------------------------------------
  // ✔ SNACKBAR
  // ---------------------------------------------------
  static void showSnack(BuildContext context, String message,
      {Color bgColor = Colors.black87}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: bgColor,
      ),
    );
  }

  // ---------------------------------------------------
  // ✔ ALERT DIALOG
  // ---------------------------------------------------
  static Future<void> showAlert(
    BuildContext context,
    String title,
    String message,
  ) async {
    return showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            child: const Text("OK"),
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
    );
  }

  // ---------------------------------------------------
  // ✔ CONFIRMATION DIALOG
  // ---------------------------------------------------
  static Future<bool> showConfirm(
    BuildContext context,
    String title,
    String message,
  ) async {
    final result = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.pop(context, false),
          ),
          ElevatedButton(
            child: const Text("OK"),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  // ---------------------------------------------------
  // ✔ VALIDATION HELPERS
  // ---------------------------------------------------
  static bool isValidEmail(String email) {
    return RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$").hasMatch(email);
  }

  static bool isValidPassword(String password) {
    return password.length >= 6;
  }

  static bool isValidAmount(String value) {
    return double.tryParse(value) != null;
  }

  static double toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is int) return value.toDouble();
    if (value is double) return value;
    return 0.0;
  }

  // ---------------------------------------------------
  // ✔ ERROR HANDLING
  // ---------------------------------------------------
  static String extractErrorMessage(dynamic e) {
    String message = e.toString();

    // Remove "Exception: " prefix
    if (message.startsWith("Exception: ")) {
      message = message.replaceFirst("Exception: ", "");
    }

    // Handle Firebase errors (often look like [firebase_functions/internal] message)
    if (message.contains("] ")) {
      message = message.split("] ").last;
    }

    // Generic cleanup
    message = message.trim();
    if (message.isEmpty) return "An unknown error occurred";

    return message;
  }
}
