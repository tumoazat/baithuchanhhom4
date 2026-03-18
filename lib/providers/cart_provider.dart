import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:baibanhang/models/cart_item.dart';
import 'package:baibanhang/models/order.dart';
import 'package:baibanhang/models/product.dart';
import 'package:baibanhang/services/cart_firestore_service.dart';
import 'package:baibanhang/services/order_service.dart';

class CartProvider extends ChangeNotifier {
  final Map<String, CartItem> _items = {};
  final List<Order> _orders = [];
  final CartService _cartService = CartService();
  final OrderService _orderService = OrderService();
  
  String? _userId;

  Map<String, CartItem> get items => UnmodifiableMapView(_items);
  List<Order> get orders => List.unmodifiable(_orders);

  bool get isEmpty => _items.isEmpty;

  int get itemCount {
    return _items.values.fold(0, (sum, item) => sum + item.quantity);
  }

  double get totalAmount {
    return _items.values.fold(0, (sum, item) => sum + item.totalPrice);
  }

  // Khởi tạo userId và tải dữ liệu từ Firestore
  Future<void> initializeWithUser(String userId) async {
    _userId = userId;
    print('🔄 Khởi tạo CartProvider với userId: $userId');
    
    try {
      // Tải giỏ hàng từ Firestore
      await loadCartFromFirebase();
      
      // Tải lịch sử đơn hàng từ Firestore
      await loadOrdersFromFirebase();
      
      print('✅ Tải dữ liệu từ Firebase thành công');
    } catch (e) {
      print('❌ Lỗi tải dữ liệu từ Firebase: $e');
    }
  }

  // Tải giỏ hàng từ Firestore
  Future<void> loadCartFromFirebase() async {
    if (_userId == null) return;
    
    try {
      final cartItems = await _cartService.getCart(_userId!);
      _items.clear();
      for (var item in cartItems) {
        _items[item.product.id] = item;
      }
      notifyListeners();
      print('📦 Tải giỏ hàng thành công: ${_items.length} sản phẩm');
    } catch (e) {
      print('❌ Lỗi tải giỏ hàng: $e');
    }
  }

  // Tải lịch sử đơn hàng từ Firestore
  Future<void> loadOrdersFromFirebase() async {
    if (_userId == null) return;
    
    try {
      final orders = await _orderService.getUserOrders(_userId!);
      _orders.clear();
      _orders.addAll(orders);
      notifyListeners();
      print('📜 Tải lịch sử đơn hàng thành công: ${_orders.length} đơn hàng');
    } catch (e) {
      print('❌ Lỗi tải lịch sử đơn hàng: $e');
    }
  }

  void addProduct(Product product) {
    final current = _items[product.id];
    if (current == null) {
      _items[product.id] = CartItem(product: product, quantity: 1);
    } else {
      _items[product.id] = current.copyWith(quantity: current.quantity + 1);
    }
    _saveCartToFirebase();
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
    _saveCartToFirebase();
    notifyListeners();
  }

  void removeProduct(String productId) {
    _items.remove(productId);
    _saveCartToFirebase();
    notifyListeners();
  }

  void clearCart() {
    if (_items.isEmpty) {
      return;
    }
    _items.clear();
    _clearCartFromFirebase();
    notifyListeners();
  }

  // Lưu giỏ hàng lên Firestore (async, không chặn UI)
  void _saveCartToFirebase() {
    if (_userId == null) return;
    
    _cartService.saveCart(
      userId: _userId!,
      items: _items.values.toList(),
    ).then((_) {
      print('💾 Giỏ hàng đã lưu lên Firebase');
    }).catchError((e) {
      print('❌ Lỗi lưu giỏ hàng: $e');
    });
  }

  // Xóa giỏ hàng khỏi Firestore
  void _clearCartFromFirebase() {
    if (_userId == null) return;
    
    _cartService.clearCart(_userId!).then((_) {
      print('🗑️ Giỏ hàng đã xóa khỏi Firebase');
    }).catchError((e) {
      print('❌ Lỗi xóa giỏ hàng: $e');
    });
  }

  Future<Order?> checkout() async {
    if (_items.isEmpty) {
      return null;
    }

    if (_userId == null) {
      throw Exception('Vui lòng đăng nhập để thanh toán');
    }

    final order = Order(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      items: _items.values
          .map((item) => item.copyWith(quantity: item.quantity))
          .toList(growable: false),
      totalPrice: totalAmount,
      createdAt: DateTime.now(),
      status: 'pending',
    );

    // Lưu đơn hàng lên Firestore
    try {
      await _orderService.createOrder(
        userId: _userId!,
        order: order,
      );
      print('✅ Đơn hàng đã tạo thành công: ${order.id}');
      
      _orders.insert(0, order);
      _items.clear();
      _clearCartFromFirebase();
      notifyListeners();
      
      return order;
    } catch (e) {
      print('❌ Lỗi tạo đơn hàng: $e');
      throw Exception('Lỗi tạo đơn hàng: $e');
    }
  }

  // Đăng xuất - xóa dữ liệu
  void logout() {
    _userId = null;
    _items.clear();
    _orders.clear();
    notifyListeners();
    print('🚪 Đã đăng xuất');
  }
}
