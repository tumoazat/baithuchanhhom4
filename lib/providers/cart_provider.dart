import 'package:flutter/foundation.dart';
import 'dart:collection';
import '../models/cart_item.dart';
import '../models/product.dart';

class CartProvider extends ChangeNotifier {
  List<CartItem> _cartItems = [];

  UnmodifiableListView<CartItem> get cartItems =>
      UnmodifiableListView(_cartItems);

  int get cartCount => _cartItems.length;

  double get totalPrice {
    return _cartItems.fold<double>(0.0, (sum, item) => sum + item.getTotalPrice());
  }

  // TODO: Implement addToCart logic when integrating with ProductDetailScreen
  void addToCart(
    Product product, {
    String? size,
    String? color,
    int quantity = 1,
  }) {
    // Placeholder for cart logic
    // This will be implemented by the responsible team member
    notifyListeners();
  }

  // TODO: Implement removeFromCart
  void removeFromCart(String cartItemId) {
    // Placeholder
    notifyListeners();
  }

  // TODO: Implement updateQuantity
  void updateQuantity(String cartItemId, int newQuantity) {
    // Placeholder
    notifyListeners();
  }

  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }
}
