import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
 final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;


  /// Registers a new user.
  ///
  Future<void> register(String name, String email, String password) async {
    print('Attempting user registration...');
    try {
      UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await userCredential.user?.updateDisplayName(name);

    } on FirebaseAuthException catch (e) {
      print('Error during registration in AuthService: ${e.code}');
 throw e;
    } catch (e) {
      // Handle other potential errors
      print('Error during registration in AuthService: $e');
      rethrow;
    }
    print('User registration and document creation finished.');
  }

  /// Logs in a user.
  Future<bool> login(String email, String password) async {
    print('Attempting user login...');
    await _firebaseAuth.signOut();

    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return true;
    } on FirebaseAuthException catch (e) {
      // Rethrow FirebaseAuthException so the UI can handle specific errors
      print('Error during login in AuthService: $e');
 throw e;
    }
    print('User login finished.');
  }

  /// Logs out the current user.
  Future<void> signOut() async {
    print('Attempting user sign out...');
    try {
      await _firebaseAuth.signOut();
      print('User signed out successfully.');
    } catch (e) {
      print('Error signing out: $e'); // Print the error for debugging
      rethrow; // Rethrow the exception
    }
  }

  /// Gets the ID of the currently logged-in user.
  /// Returns null if no user is logged in.
 String? getCurrentUserId() => _firebaseAuth.currentUser?.uid;

  /// Provides a stream of authentication state changes.
 Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();
}