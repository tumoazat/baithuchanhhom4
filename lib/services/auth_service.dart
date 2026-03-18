import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'user_service.dart';

class AuthService {
  static const _keyLoggedIn = 'auth_logged_in';
  static const _keyEmail = 'auth_email';
  static const _keyUserId = 'auth_user_id';

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final UserService _userService = UserService();

  Future<bool> isLoggedIn() async {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      return true;
    }
    
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyLoggedIn) ?? false;
  }

  Future<String?> getCurrentEmail() async {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      return user.email;
    }
    
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyEmail);
  }

  Future<String?> getCurrentUserId() async {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      return user.uid;
    }
    
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserId);
  }

  Future<void> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    if (email.trim().isEmpty || password.trim().isEmpty) {
      throw Exception('Vui lòng nhập đầy đủ email và mật khẩu.');
    }

    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(email.trim())) {
      throw Exception('Email không hợp lệ.');
    }

    if (password.length < 6) {
      throw Exception('Mật khẩu phải có ít nhất 6 ký tự.');
    }

    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final user = userCredential.user;
      if (user != null) {
        // Lưu người dùng vào Firestore
        await _userService.saveOrUpdateUser(
          uid: user.uid,
          email: user.email ?? '',
        );

        // Lưu vào SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_keyLoggedIn, true);
        await prefs.setString(_keyEmail, user.email ?? '');
        await prefs.setString(_keyUserId, user.uid);

        print('✅ Đăng ký thành công! UID: ${user.uid}');
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        throw Exception('Email này đã được đăng ký.');
      } else if (e.code == 'weak-password') {
        throw Exception('Mật khẩu quá yếu.');
      } else {
        throw Exception('Lỗi đăng ký: ${e.message}');
      }
    }
  }

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    if (email.trim().isEmpty || password.trim().isEmpty) {
      throw Exception('Vui lòng nhập đầy đủ email và mật khẩu.');
    }

    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final user = userCredential.user;
      if (user != null) {
        // Cập nhật người dùng vào Firestore
        await _userService.saveOrUpdateUser(
          uid: user.uid,
          email: user.email ?? '',
        );

        // Lưu vào SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_keyLoggedIn, true);
        await prefs.setString(_keyEmail, user.email ?? '');
        await prefs.setString(_keyUserId, user.uid);

        print('✅ Đăng nhập thành công! UID: ${user.uid}');
        print('📧 Email: ${user.email}');
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw Exception('Email này không có tài khoản.');
      } else if (e.code == 'wrong-password') {
        throw Exception('Mật khẩu không đúng.');
      } else if (e.code == 'invalid-email') {
        throw Exception('Email không hợp lệ.');
      } else {
        throw Exception('Lỗi đăng nhập: ${e.message}');
      }
    }
  }

  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
      print('✅ Đã đăng xuất');
    } catch (e) {
      print('❌ Lỗi đăng xuất: $e');
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyLoggedIn);
    await prefs.remove(_keyEmail);
    await prefs.remove(_keyUserId);
  }

  Future<void> resetPassword(String email) async {
    if (email.trim().isEmpty) {
      throw Exception('Vui lòng nhập email.');
    }

    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
      print('✅ Email đặt lại mật khẩu đã được gửi');
    } on FirebaseAuthException catch (e) {
      throw Exception('Lỗi: ${e.message}');
    }
  }
}
