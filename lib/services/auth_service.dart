import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const _keyLoggedIn = 'auth_logged_in';
  static const _keyEmail = 'auth_email';

  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyLoggedIn) ?? false;
  }

  Future<String?> getCurrentEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyEmail);
  }

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    if (email.trim().isEmpty || password.trim().isEmpty) {
      throw Exception('Vui long nhap day du email va mat khau.');
    }

    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(email.trim())) {
      throw Exception('Email khong hop le.');
    }

    if (!email.trim().toLowerCase().endsWith('@gmail.com')) {
      throw Exception('Vui long dung Gmail de dang nhap.');
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyLoggedIn, true);
    await prefs.setString(_keyEmail, email.trim());
  }

  Future<String> signInWithGoogle() async {
    final account = await _googleSignIn.signIn();
    if (account == null) {
      throw Exception('Ban da huy dang nhap Google.');
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyLoggedIn, true);
    await prefs.setString(_keyEmail, account.email);
    return account.email;
  }

  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyLoggedIn);
    await prefs.remove(_keyEmail);

    try {
      await _googleSignIn.signOut();
    } catch (_) {
      // Ignore Google sign-out failures for local session cleanup.
    }
  }
}
