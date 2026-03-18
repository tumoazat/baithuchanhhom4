import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../screens/home_screen.dart';
import '../screens/login_screen.dart';
import '../services/auth_service.dart';

class SignupScreen extends StatefulWidget {
  static const String routeName = '/signup';

  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authService = AuthService();
  bool _loading = false;
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    final email = _emailController.text;
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    // Validate
    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng điền đầy đủ thông tin')),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mật khẩu không trùng khớp')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      await _authService.signUpWithEmail(email: email, password: password);
      
      if (!mounted) return;
      
      // Khởi tạo CartProvider với userId mới
      final userId = await _authService.getCurrentUserId();
      if (userId != null && mounted) {
        final cartProvider = context.read<CartProvider>();
        await cartProvider.initializeWithUser(userId);
        print('✅ Giỏ hàng được khởi tạo sau đăng ký: $userId');
      }
      
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, HomeScreen.routeName);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Icon(
                        Icons.shopping_bag_outlined,
                        size: 48,
                        color: theme.primaryColor,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Đăng Ký Tài Khoản',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        enabled: !_loading,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _passwordController,
                        enabled: !_loading,
                        obscureText: !_passwordVisible,
                        decoration: InputDecoration(
                          labelText: 'Mật khẩu',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.lock_outlined),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _passwordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(
                                () => _passwordVisible = !_passwordVisible,
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _confirmPasswordController,
                        enabled: !_loading,
                        obscureText: !_confirmPasswordVisible,
                        decoration: InputDecoration(
                          labelText: 'Xác nhận mật khẩu',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.lock_outlined),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _confirmPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(
                                () =>
                                    _confirmPasswordVisible =
                                        !_confirmPasswordVisible,
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 46,
                        child: FilledButton(
                          onPressed: _loading ? null : _signUp,
                          child: _loading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor:
                                        AlwaysStoppedAnimation<Color>(
                                          Colors.white,
                                        ),
                                  ),
                                )
                              : const Text('Đăng Ký'),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Đã có tài khoản? '),
                          TextButton(
                            onPressed: _loading
                                ? null
                                : () {
                                    Navigator.pushReplacementNamed(
                                      context,
                                      LoginScreen.routeName,
                                    );
                                  },
                            child: const Text('Đăng nhập'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
