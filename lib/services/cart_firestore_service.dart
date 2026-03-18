import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/cart_item.dart';

class CartService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _cartsCollection = 'carts';

  /// Lưu giỏ hàng vào Firestore
  Future<void> saveCart({
    required String userId,
    required List<CartItem> items,
  }) async {
    try {
      double total = 0;
      for (var item in items) {
        total += item.totalPrice;
      }

      await _firestore.collection(_cartsCollection).doc(userId).set(
        {
          'userId': userId,
          'items': items.map((item) => item.toJson()).toList(),
          'total': total,
          'itemCount': items.length,
          'updatedAt': FieldValue.serverTimestamp(),
        },
      );
      print('✅ Giỏ hàng đã được lưu cho user: $userId');
    } catch (e) {
      print('❌ Lỗi khi lưu giỏ hàng: $e');
      throw Exception('Lỗi lưu giỏ hàng: $e');
    }
  }

  /// Lấy giỏ hàng từ Firestore
  Future<List<CartItem>> getCart(String userId) async {
    try {
      final doc = await _firestore.collection(_cartsCollection).doc(userId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        final itemsList = data['items'] as List<dynamic>? ?? [];
        return itemsList
            .map((item) => CartItem.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      print('❌ Lỗi khi lấy giỏ hàng: $e');
      return [];
    }
  }

  /// Xóa giỏ hàng
  Future<void> clearCart(String userId) async {
    try {
      await _firestore.collection(_cartsCollection).doc(userId).delete();
      print('✅ Giỏ hàng đã được xóa cho user: $userId');
    } catch (e) {
      print('❌ Lỗi khi xóa giỏ hàng: $e');
      throw Exception('Lỗi xóa giỏ hàng: $e');
    }
  }

  /// Cập nhật một item trong giỏ
  Future<void> updateCartItem({
    required String userId,
    required String productId,
    required int quantity,
  }) async {
    try {
      final cartDoc =
          await _firestore.collection(_cartsCollection).doc(userId).get();
      if (cartDoc.exists) {
        final data = cartDoc.data() as Map<String, dynamic>;
        final items = (data['items'] as List<dynamic>? ?? [])
            .map((item) => CartItem.fromJson(item as Map<String, dynamic>))
            .toList();

        final itemIndex = items.indexWhere(
            (item) => item.product.id == productId);
        if (itemIndex != -1) {
          if (quantity > 0) {
            items[itemIndex] = items[itemIndex].copyWith(quantity: quantity);
          } else {
            items.removeAt(itemIndex);
          }

          await saveCart(userId: userId, items: items);
        }
      }
    } catch (e) {
      print('❌ Lỗi cập nhật item: $e');
      throw Exception('Lỗi cập nhật item giỏ hàng: $e');
    }
  }

  /// Xóa một item khỏi giỏ
  Future<void> removeFromCart({
    required String userId,
    required String productId,
  }) async {
    try {
      final cartDoc =
          await _firestore.collection(_cartsCollection).doc(userId).get();
      if (cartDoc.exists) {
        final data = cartDoc.data() as Map<String, dynamic>;
        final items = (data['items'] as List<dynamic>? ?? [])
            .map((item) => CartItem.fromJson(item as Map<String, dynamic>))
            .toList();

        items.removeWhere((item) => item.product.id == productId);
        await saveCart(userId: userId, items: items);
      }
    } catch (e) {
      print('❌ Lỗi xóa item: $e');
      throw Exception('Lỗi xóa item khỏi giỏ hàng: $e');
    }
  }

  /// Lấy tổng số item trong giỏ
  Future<int> getCartItemCount(String userId) async {
    try {
      final doc = await _firestore.collection(_cartsCollection).doc(userId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return data['itemCount'] as int? ?? 0;
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  /// Lấy tổng giá giỏ hàng
  Future<double> getCartTotal(String userId) async {
    try {
      final doc = await _firestore.collection(_cartsCollection).doc(userId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return (data['total'] as num? ?? 0).toDouble();
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }
}
