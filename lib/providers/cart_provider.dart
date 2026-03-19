import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:baibanhang/models/cart_item.dart';
import 'package:baibanhang/models/order.dart';
import 'package:baibanhang/models/product.dart';

class CartProvider extends ChangeNotifier {
  final Map<String, CartItem> _items = {};
  final List<Order> _orders = [];

  // Chi expose read-only de UI khong thay doi state truc tiep.
  Map<String, CartItem> get items => UnmodifiableMapView(_items);
  List<Order> get orders => List.unmodifiable(_orders);

  bool get isEmpty => _items.isEmpty;

  int get itemCount {
    // Dem tong so luong san pham (khong phai so dong item).
    return _items.values.fold(0, (sum, item) => sum + item.quantity);
  }

  double get totalAmount {
    // Tong tien = tong (gia * so luong) cua tung item.
    return _items.values.fold(0, (sum, item) => sum + item.totalPrice);
  }

  void addProduct(Product product) {
    final current = _items[product.id];
    if (current == null) {
      _items[product.id] = CartItem(product: product, quantity: 1);
    } else {
      _items[product.id] = current.copyWith(quantity: current.quantity + 1);
    }
    notifyListeners();
  }

  void decreaseQuantity(String productId) {
    final current = _items[productId];
    if (current == null) {
      return;
    }

    if (current.quantity <= 1) {
      _items.remove(productId);
    } else {
      _items[productId] = current.copyWith(quantity: current.quantity - 1);
    }
    notifyListeners();
  }

  void removeProduct(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void clearCart() {
    if (_items.isEmpty) {
      return;
    }
    _items.clear();
    notifyListeners();
  }

  Order? checkout() {
    if (_items.isEmpty) {
      return null;
    }

    // Tao snapshot item tai thoi diem checkout de luu lich su don hang.
    final order = Order(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      items: _items.values
          .map((item) => item.copyWith(quantity: item.quantity))
          .toList(growable: false),
      totalAmount: totalAmount,
      createdAt: DateTime.now(),
    );

    // Chen vao dau danh sach de don moi nhat hien thi truoc.
    _orders.insert(0, order);
    _items.clear();
    notifyListeners();
    return order;
  }
}
