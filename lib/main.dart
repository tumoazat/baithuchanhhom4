import 'package:baibanhang/models/product.dart';
import 'package:baibanhang/providers/cart_provider.dart';
import 'package:baibanhang/screens/cart_screen.dart';
import 'package:baibanhang/screens/checkout_screen.dart';
import 'package:baibanhang/screens/home_screen.dart';
import 'package:baibanhang/screens/login_screen.dart';
import 'package:baibanhang/screens/order_history_screen.dart';
import 'package:baibanhang/screens/product_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CartProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Baibanhang',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFFF6A00),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFFF5F5F7),
          appBarTheme: const AppBarTheme(
            centerTitle: false,
            backgroundColor: Colors.white,
            foregroundColor: Color(0xFF0F172A),
            surfaceTintColor: Colors.transparent,
            elevation: 0,
          ),
          cardTheme: CardThemeData(
            color: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          chipTheme: ChipThemeData(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ),
        initialRoute: LoginScreen.routeName,
        routes: {
          LoginScreen.routeName: (context) => const LoginScreen(),
          HomeScreen.routeName: (context) => const HomeScreen(),
          CartScreen.routeName: (context) => const CartScreen(),
          CheckoutScreen.routeName: (context) => const CheckoutScreen(),
          OrderHistoryScreen.routeName: (context) => const OrderHistoryScreen(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == ProductDetailScreen.routeName) {
            final data = settings.arguments;
            if (data is Product) {
              return MaterialPageRoute(
                builder: (context) => ProductDetailScreen(product: data),
              );
            }
          }

          return MaterialPageRoute(builder: (context) => const HomeScreen());
        },
      ),
    );
  }
}
