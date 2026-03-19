import 'package:baibanhang/models/product.dart';
import 'package:baibanhang/providers/cart_provider.dart';
import 'package:baibanhang/screens/cart_screen.dart';
import 'package:baibanhang/screens/checkout_screen.dart';
import 'package:baibanhang/screens/home_screen.dart';
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
    // Dat CartProvider o root de moi man hinh co the doc/cap nhat gio hang.
    return ChangeNotifierProvider(
      create: (_) => CartProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Baibanhang',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
          useMaterial3: true,
        ),
        initialRoute: HomeScreen.routeName,
        routes: {
          HomeScreen.routeName: (context) => const HomeScreen(),
          CartScreen.routeName: (context) => const CartScreen(),
          CheckoutScreen.routeName: (context) => const CheckoutScreen(),
          OrderHistoryScreen.routeName: (context) => const OrderHistoryScreen(),
        },
        onGenerateRoute: (settings) {
          // Route chi tiet can tham so Product nen xu ly qua onGenerateRoute.
          if (settings.name == ProductDetailScreen.routeName) {
            final data = settings.arguments;
            if (data is Product) {
              return MaterialPageRoute(
                builder: (context) => ProductDetailScreen(product: data),
              );
            }
          }

          // Fallback an toan neu route/arguments khong hop le.
          return MaterialPageRoute(builder: (context) => const HomeScreen());
        },
      ),
    );
  }
}
