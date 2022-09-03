import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:incom/services/user.service.dart';
import '../models/app_user.model.dart';

class FirebaseService {
  static Future<AppUser?> findUserByEmail(String email) async {
    final doc =
    await FirebaseFirestore.instance.collection("users").doc(email).get();
    if (!doc.exists) {
      return null;
    }
    final currentUser = AppUser.fromMap(doc.data() as Map<String, dynamic>);
    UserService.to.currentUser.value = currentUser;
    return currentUser;
  }


  static Future<AppUser?> getCurrentUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return null;
    }
    return findUserByEmail(user.email!);
  }
}