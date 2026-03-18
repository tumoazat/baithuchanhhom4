import 'package:baibanhang/models/cart_item.dart';
import 'package:baibanhang/models/order.dart';
import 'package:cloud_firestore/cloud_firestore.dart' hide Order;

/// Service để sync dữ liệu từ Firestore cho user
class FirestoreSyncService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Lấy giỏ hàng của user từ Firestore
  Future<List<CartItem>> loadUserCart(String userId) async {
    try {
      print('📥 Đang tải giỏ hàng từ Firestore cho user: $userId');
      final doc = await _firestore.collection('carts').doc(userId).get();
      
      if (!doc.exists) {
        print('⚠️ Không tìm thấy giỏ hàng cho user: $userId');
        return [];
      }

      final data = doc.data() as Map<String, dynamic>;
      final itemsList = data['items'] as List<dynamic>? ?? [];
      
      final cartItems = itemsList
          .map((item) => CartItem.fromJson(item as Map<String, dynamic>))
          .toList();
      
      print('✅ Tải giỏ hàng thành công: ${cartItems.length} sản phẩm');
      return cartItems;
    } catch (e) {
      print('❌ Lỗi khi tải giỏ hàng: $e');
      return [];
    }
  }

  /// Lấy lịch sử đơn hàng của user từ Firestore
  Future<List<Order>> loadUserOrders(String userId) async {
    try {
      print('📥 Đang tải lịch sử đơn hàng từ Firestore cho user: $userId');
      
      final snapshot = await _firestore
          .collection('orders')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      final orders = snapshot.docs
          .map((doc) => Order.fromFirestore(doc.data(), doc.id))
          .toList();

      print('✅ Tải lịch sử đơn hàng thành công: ${orders.length} đơn hàng');
      return orders;
    } catch (e) {
      print('❌ Lỗi khi tải lịch sử đơn hàng: $e');
      return [];
    }
  }

  /// Lưu giỏ hàng vào Firestore
  Future<void> saveUserCart(String userId, List<CartItem> items) async {
    try {
      print('💾 Đang lưu giỏ hàng cho user: $userId (${items.length} sản phẩm)');
      
      double total = 0;
      for (var item in items) {
        total += item.totalPrice;
      }

      await _firestore.collection('carts').doc(userId).set(
        {
          'userId': userId,
          'items': items.map((item) => item.toJson()).toList(),
          'total': total,
          'itemCount': items.length,
          'updatedAt': FieldValue.serverTimestamp(),
        },
      );
      
      print('✅ Giỏ hàng đã lưu thành công');
    } catch (e) {
      print('❌ Lỗi khi lưu giỏ hàng: $e');
      throw Exception('Lỗi lưu giỏ hàng: $e');
    }
  }

  /// Xóa giỏ hàng của user
  Future<void> clearUserCart(String userId) async {
    try {
      print('🗑️ Đang xóa giỏ hàng cho user: $userId');
      await _firestore.collection('carts').doc(userId).delete();
      print('✅ Giỏ hàng đã xóa thành công');
    } catch (e) {
      print('❌ Lỗi khi xóa giỏ hàng: $e');
      throw Exception('Lỗi xóa giỏ hàng: $e');
    }
  }

  /// Tạo đơn hàng mới
  Future<String> createOrder(String userId, Order order) async {
    try {
      print('📝 Đang tạo đơn hàng cho user: $userId');
      
      final docRef = await _firestore.collection('orders').add({
        'userId': userId,
        'items': order.items?.map((item) => item.toJson()).toList() ?? [],
        'totalPrice': order.totalPrice,
        'status': order.status ?? 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'deliveryAddress': order.deliveryAddress ?? '',
        'phoneNumber': order.phoneNumber ?? '',
        'paymentMethod': order.paymentMethod ?? 'COD',
        'notes': order.notes ?? '',
      });
      
      print('✅ Đơn hàng đã tạo thành công: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('❌ Lỗi khi tạo đơn hàng: $e');
      throw Exception('Lỗi tạo đơn hàng: $e');
    }
  }

  /// Kiểm tra giỏ hàng có tồn tại không
  Future<bool> hasCart(String userId) async {
    try {
      final doc = await _firestore.collection('carts').doc(userId).get();
      return doc.exists;
    } catch (e) {
      print('❌ Lỗi khi kiểm tra giỏ hàng: $e');
      return false;
    }
  }

  /// Lấy số lượng đơn hàng của user
  Future<int> getOrderCount(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('orders')
          .where('userId', isEqualTo: userId)
          .count()
          .get();
      
      return snapshot.count ?? 0;
    } catch (e) {
      print('❌ Lỗi khi đếm đơn hàng: $e');
      return 0;
    }
  }
}
