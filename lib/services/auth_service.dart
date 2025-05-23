import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
 final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;


  /// Registers a new user.
  ///
  Future<void> register(String name, String email, String password) async {
    try {
      UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await userCredential.user?.updateDisplayName(name);
    } on FirebaseAuthException catch (e) {
      // Rethrow FirebaseAuthException so the UI can handle specific errors
 throw e;
    } catch (e) {
      // Handle other potential errors
      rethrow;
    }
  }

  /// Logs in a user.
  Future<bool> login(String email, String password) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return true;
    } on FirebaseAuthException catch (e) {
      // Rethrow FirebaseAuthException so the UI can handle specific errors
 throw e;
    }
  }

  /// Logs out the current user.
  Future<void> signOut() async {
 await _firebaseAuth.signOut();
  }

  /// Gets the ID of the currently logged-in user.
  /// Returns null if no user is logged in.
 String? getCurrentUserId() => _firebaseAuth.currentUser?.uid;

  /// Provides a stream of authentication state changes.
 Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();
}