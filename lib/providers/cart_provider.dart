import 'package:flutter/foundation.dart';

import '../models/cart_item.dart';
import '../models/product.dart';
import '../services/cart_local_storage.dart';

class CartProvider extends ChangeNotifier {
  final CartLocalStorage _storage = CartLocalStorage();
  List<CartItem> _items = [];

  CartProvider() {
    _loadCartFromStorage();
  }

  List<CartItem> get items => List.unmodifiable(_items);

  int get itemCount => _items.length;

  double get totalSelectedPrice {
    return _items
        .where((item) => item.isChecked)
        .fold(0.0, (sum, item) => sum + item.total);
  }

  int get totalSelectedQuantity {
    return _items
        .where((item) => item.isChecked)
        .fold(0, (sum, item) => sum + item.quantity);
  }

  bool get isAllSelected {
    if (_items.isEmpty) return false;
    return _items.every((item) => item.isChecked);
  }

  void addToCart({
    required Product product,
    required String size,
    required String color,
    int quantity = 1,
  }) {
    final existingIndex = _items.indexWhere(
      (item) =>
          item.productId == product.id &&
          item.selectedSize == size &&
          item.selectedColor == color,
    );

    if (existingIndex >= 0) {
      final existing = _items[existingIndex];
      _items[existingIndex] = CartItem(
        id: existing.id,
        productId: existing.productId,
        title: existing.title,
        price: existing.price,
        imageUrl: existing.imageUrl,
        selectedSize: existing.selectedSize,
        selectedColor: existing.selectedColor,
        quantity: existing.quantity + quantity,
        isChecked: existing.isChecked,
      );
    } else {
      _items.add(
        CartItem(
          id: '${product.id}-$size-$color',
          productId: product.id,
          title: product.title,
          price: product.price,
          imageUrl: product.imageUrl,
          selectedSize: size,
          selectedColor: color,
          quantity: quantity,
        ),
      );
    }

    _save();
  }

  void removeItem(String cartItemId) {
    _items.removeWhere((item) => item.id == cartItemId);
    _save();
  }

  void clear() {
    _items.clear();
    _save();
  }

  void toggleCheck(String cartItemId) {
    final index = _items.indexWhere((item) => item.id == cartItemId);
    if (index < 0) return;
    final current = _items[index];
    _items[index] = CartItem(
      id: current.id,
      productId: current.productId,
      title: current.title,
      price: current.price,
      imageUrl: current.imageUrl,
      selectedSize: current.selectedSize,
      selectedColor: current.selectedColor,
      quantity: current.quantity,
      isChecked: !current.isChecked,
    );
    _save();
  }

  void toggleCheckAll(bool value) {
    for (var i = 0; i < _items.length; i++) {
      final current = _items[i];
      _items[i] = CartItem(
        id: current.id,
        productId: current.productId,
        title: current.title,
        price: current.price,
        imageUrl: current.imageUrl,
        selectedSize: current.selectedSize,
        selectedColor: current.selectedColor,
        quantity: current.quantity,
        isChecked: value,
      );
    }
    _save();
  }

  void increaseQuantity(String cartItemId) {
    final index = _items.indexWhere((item) => item.id == cartItemId);
    if (index < 0) return;
    final current = _items[index];
    _items[index] = CartItem(
      id: current.id,
      productId: current.productId,
      title: current.title,
      price: current.price,
      imageUrl: current.imageUrl,
      selectedSize: current.selectedSize,
      selectedColor: current.selectedColor,
      quantity: current.quantity + 1,
      isChecked: current.isChecked,
    );
    _save();
  }

  void decreaseQuantity(String cartItemId) {
    final index = _items.indexWhere((item) => item.id == cartItemId);
    if (index < 0) return;
    final current = _items[index];
    if (current.quantity <= 1) {
      // Leave removal to UI confirmation.
      return;
    }

    _items[index] = CartItem(
      id: current.id,
      productId: current.productId,
      title: current.title,
      price: current.price,
      imageUrl: current.imageUrl,
      selectedSize: current.selectedSize,
      selectedColor: current.selectedColor,
      quantity: current.quantity - 1,
      isChecked: current.isChecked,
    );
    _save();
  }

  Future<void> loadCartFromStorage() async {
    final loaded = await _storage.loadCart();
    _items = loaded;
    notifyListeners();
  }

  void _loadCartFromStorage() {
    // Fire-and-forget; listener will be notified once loaded.
    loadCartFromStorage();
  }

  void _save() {
    _storage.saveCart(_items);
    notifyListeners();
  }
}
