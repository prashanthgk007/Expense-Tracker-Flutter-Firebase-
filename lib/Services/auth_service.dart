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
    final uid = currentUserId;
    if (uid == null) throw Exception("User not logged in");

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (doc.exists) {
        
        return doc.data() ?? {};
      } else {
        throw Exception("Profile not found");
      }
    } catch (e) {
      throw Exception("Failed to get profile: $e");
    }
  }

  Future<UserModel?> updateUserProfile({
    String? name,
    String? email,
    String? password,
  }) async {
    final uid = currentUserId;
    if (uid == null) throw Exception("User not logged in");

    try {
      final Map<String, dynamic> updateData = {
        'updatedAt': FieldValue.serverTimestamp(),
      };
      
      if (name != null) updateData['name'] = name;
      if (email != null) updateData['email'] = email;
      
      // Update Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .set(updateData, SetOptions(merge: true));
      
      // Update Auth (Email/Password) - This REQUIRES online.
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
         try {
           if (email != null && email != user.email) {
             await user.verifyBeforeUpdateEmail(email); // or updateEmail
           }
           if (password != null) {
             await user.updatePassword(password);
           }
           if (name != null) {
             await user.updateDisplayName(name);
           }
         } catch (e) {
           print("Auth update failed (might be offline): $e");
           // We continue because local Firestore update succeeded (persisted).
         }
      }

      // Return updated model
      // Fetch latest
       final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
          
       if (doc.exists) {
         return UserModel.fromMap(doc.data()!);
       }
       return null;
       
    } catch (e) {
      print("Update profile failed: $e");
      return null;
    }
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
