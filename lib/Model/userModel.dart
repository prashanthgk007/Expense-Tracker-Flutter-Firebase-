class UserModel {
  final String uid;
  final String username;
  final String email;

  UserModel({
    required this.uid,
    required this.username,
    required this.email,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    final userMap = map['user'] ?? map; // handle nested 'user' key if exists
    return UserModel(
      uid: userMap['uid'] ?? '',
      username: userMap['username'] ?? '',
      email: userMap['email'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'username': username,
      'email': email,
    };
  }
}
