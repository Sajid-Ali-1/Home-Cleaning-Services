import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:home_cleaning_app/models/user_model.dart';

class DbServices {
  static CollectionReference usersRef = FirebaseFirestore.instance.collection(
    'users',
  );
  static CollectionReference gardenRef = FirebaseFirestore.instance.collection(
    'garden',
  );
  static CollectionReference gardenInviteRef = FirebaseFirestore.instance
      .collection('gardenInvites');

  static CollectionReference gratitudeEntriesRef(String gardenId) {
    return gardenRef.doc(gardenId).collection('gratitude_entries');
  }

  static CollectionReference streakRef(String userId) {
    return usersRef.doc(userId).collection('streak');
  }
  // -------------------- User Data Management -------------------

  static Future<void> addUserData(UserModel user) async {
    try {
      await usersRef.doc(user.uid).set(user.toMap());
    } catch (e) {
      throw Exception('Failed to add user data: $e');
    }
  }

  static Future<UserModel?> getUserData(String uid) async {
    try {
      DocumentSnapshot doc = await usersRef.doc(uid).get();
      if (doc.exists) {
        return UserModel.fromDocument(doc);
      } else {
        return null;
      }
    } catch (e) {
      throw Exception('Failed to get user data: $e');
    }
  }

  /// Check if a cleaner is verified
  static Future<bool> isCleanerVerified(String uid) async {
    try {
      UserModel? user = await getUserData(uid);
      return user?.isVerified ?? false;
    } catch (e) {
      throw Exception('Failed to check cleaner verification: $e');
    }
  }
}
