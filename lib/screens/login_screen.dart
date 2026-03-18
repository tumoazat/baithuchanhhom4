import 'package:baibanhang/providers/cart_provider.dart';
import 'package:baibanhang/screens/home_screen.dart';
import 'package:baibanhang/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  static const routeName = '/login';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _authService = AuthService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _restoreSession();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _restoreSession() async {
    final loggedIn = await _authService.isLoggedIn();
    if (!mounted || !loggedIn) {
      return;
    }

    Navigator.pushReplacementNamed(context, HomeScreen.routeName);
  }

  Future<void> _signInEmail() async {
    setState(() => _loading = true);
    try {
      await _authService.signInWithEmail(
        email: _emailController.text,
        password: _passwordController.text,
      );
      
      if (!mounted) return;
      
      // Khởi tạo CartProvider với userId mới
      final userId = await _authService.getCurrentUserId();
      if (userId != null && mounted) {
        final cartProvider = context.read<CartProvider>();
        await cartProvider.initializeWithUser(userId);
        print('✅ Giỏ hàng được khởi tạo sau đăng nhập: $userId');
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
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Dang nhap',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Dang nhap bang Google hoac Email',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 18),
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Mat khau',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 46,
                        child: FilledButton(
                          onPressed: _loading ? null : _signInEmail,
                          child: _loading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text('Dang nhap Email'),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Chưa có tài khoản? '),
                          TextButton(
                            onPressed: _loading
                                ? null
                                : () => Navigator.pushNamed(
                                      context,
                                      '/signup',
                                    ),
                            child: const Text('Đăng ký'),
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
