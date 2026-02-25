import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthServices {
  static final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  static Future<User?> signUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      // Update the display name
      await userCredential.user?.updateDisplayName(fullName);

      // Send email verification
      if (userCredential.user != null && !userCredential.user!.emailVerified) {
        await userCredential.user!.sendEmailVerification();
      }

      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      if (e is Exception) {
        throw e;
      }
      throw Exception('An unknown error occurred');
    }
  }

  static Future<User?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      // Reload user to get latest email verification status
      if (userCredential.user != null) {
        await userCredential.user!.reload();
        // Get the updated user after reload
        return FirebaseAuth.instance.currentUser;
      }

      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      if (e is Exception) {
        throw e;
      }
      throw Exception('An unknown error occurred');
    }
  }

  static Future<void> signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      await _googleSignIn.signOut();
    } catch (e) {
      throw Exception('Failed to sign out: $e');
    }
  }

  /// Send email verification to the current user
  static Future<void> sendEmailVerification() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
      } else if (user == null) {
        throw Exception('No user is currently signed in');
      } else {
        throw Exception('Email is already verified');
      }
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      if (e is Exception) {
        throw e;
      }
      throw Exception('Failed to send verification email: $e');
    }
  }

  /// Reload the current user to get updated email verification status
  static Future<void> reloadUser() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.reload();
      }
    } catch (e) {
      throw Exception('Failed to reload user: $e');
    }
  }

  /// Check if the current user's email is verified
  static bool isEmailVerified() {
    User? user = FirebaseAuth.instance.currentUser;
    return user?.emailVerified ?? false;
  }
}
