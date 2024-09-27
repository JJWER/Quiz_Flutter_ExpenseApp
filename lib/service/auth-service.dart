import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ลงทะเบียนผู้ใช้ใหม่
  Future<String> registration({
    required String email,
    required String password,
    required String confirm,
  }) async {
    // ตรวจสอบว่ารหัสผ่านตรงกันหรือไม่
    if (password != confirm) {
      return 'Passwords do not match';
    }

    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return 'Registration successful';
    } on FirebaseAuthException catch (e) {
      // แสดงข้อความข้อผิดพลาดที่ชัดเจน
      switch (e.code) {
        case 'weak-password':
          return 'The password provided is too weak.';
        case 'email-already-in-use':
          return 'The account already exists for that email.';
        case 'invalid-email':
          return 'The email address is not valid.';
        default:
          return e.message ?? 'An error occurred during registration';
      }
    } catch (e) {
      return 'An unknown error occurred: ${e.toString()}';
    }
  }

  // เข้าสู่ระบบ
  Future<String> signin({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return 'Sign-in successful';
    } on FirebaseAuthException catch (e) {
      // แสดงข้อความข้อผิดพลาดที่ชัดเจน
      switch (e.code) {
        case 'user-not-found':
          return 'No user found for that email.';
        case 'wrong-password':
          return 'Wrong password provided.';
        case 'invalid-email':
          return 'The email address is not valid.';
        default:
          return e.message ?? 'An error occurred during sign-in';
      }
    } catch (e) {
      return 'An unknown error occurred: ${e.toString()}';
    }
  }

  // ออกจากระบบ
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Error signing out: ${e.toString()}');
    }
  }

  // ตรวจสอบสถานะล็อกอิน (ตรวจสอบว่ามีผู้ใช้ล็อกอินอยู่หรือไม่)
  User? get currentUser {
    return _auth.currentUser;
  }

  // ตรวจสอบการเข้าสู่ระบบ
  bool isSignedIn() {
    return _auth.currentUser != null;
  }
}
