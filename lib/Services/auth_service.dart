import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:expense_tracker_app/Helper/utilities.dart';
import 'package:expense_tracker_app/Model/userModel.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  Future<UserCredential> login(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<Map<String, dynamic>> getUserProfile() async {
    final callable = FirebaseFunctions.instance.httpsCallable("getUserProfile");
    final response = await callable.call();
    return Map<String, dynamic>.from(response.data);
  }

  Future<UserModel?> updateUserProfile({
    String? name,
    String? email,
    String? password,
  }) async {
    final callable = FirebaseFunctions.instance.httpsCallable(
      "updateUserProfile",
    );

    final response = await callable.call({
      "name": name,
      "email": email,
      "password": password,
    });

    if (response.data["success"] == true && response.data["user"] != null) {
      return UserModel.fromMap(
        Map<String, dynamic>.from(response.data["user"]),
      );
    }

    return null;
  }

  Future<bool> signup(String email, String password, String username) async {
    final callable = FirebaseFunctions.instance.httpsCallable("signupUser");

    try {
      final response = await callable.call({
        "email": email,
        "password": password,
        "username": username,
      });

      // Firebase Auth login required after function creates account
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return response.data["success"] == true;
    } catch (e) {
      AppUtils.showError("Failed to sign up");
      return false;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw Exception("Failed to send reset email: ${e.toString()}");
    }
  }
}
