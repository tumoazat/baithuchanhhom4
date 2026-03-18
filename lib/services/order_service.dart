import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import '../models/order.dart';

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _ordersCollection = 'orders';

  /// Tạo đơn hàng mới
  Future<String> createOrder({
    required String userId,
    required Order order,
  }) async {
    try {
      final docRef = await _firestore.collection(_ordersCollection).add({
        'userId': userId,
        'items': order.items?.map((item) => item.toJson()).toList() ?? [],
        'totalPrice': order.totalPrice,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'deliveryAddress': order.deliveryAddress ?? '',
        'phoneNumber': order.phoneNumber ?? '',
        'paymentMethod': order.paymentMethod ?? 'COD',
        'notes': order.notes ?? '',
      });
      print('✅ Đơn hàng đã được tạo: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('❌ Lỗi khi tạo đơn hàng: $e');
      throw Exception('Lỗi tạo đơn hàng: $e');
    }
  }

  /// Lấy tất cả đơn hàng của người dùng
  Future<List<Order>> getUserOrders(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_ordersCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Order.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('❌ Lỗi khi lấy đơn hàng: $e');
      return [];
    }
  }

  /// Lấy chi tiết đơn hàng
  Future<Order?> getOrderById(String orderId) async {
    try {
      final doc = await _firestore
          .collection(_ordersCollection)
          .doc(orderId)
          .get();
      if (doc.exists) {
        return Order.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      print('❌ Lỗi khi lấy chi tiết đơn hàng: $e');
      return null;
    }
  }

  /// Cập nhật trạng thái đơn hàng
  Future<void> updateOrderStatus({
    required String orderId,
    required String status,
  }) async {
    try {
      await _firestore.collection(_ordersCollection).doc(orderId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('✅ Trạng thái đơn hàng đã được cập nhật: $orderId -> $status');
    } catch (e) {
      print('❌ Lỗi cập nhật trạng thái: $e');
      throw Exception('Lỗi cập nhật trạng thái: $e');
    }
  }

  /// Hủy đơn hàng
  Future<void> cancelOrder(String orderId) async {
    try {
      await _firestore.collection(_ordersCollection).doc(orderId).update({
        'status': 'cancelled',
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('✅ Đơn hàng đã được hủy: $orderId');
    } catch (e) {
      print('❌ Lỗi hủy đơn hàng: $e');
      throw Exception('Lỗi hủy đơn hàng: $e');
    }
  }

  /// Xóa đơn hàng (admin only)
  Future<void> deleteOrder(String orderId) async {
    try {
      await _firestore.collection(_ordersCollection).doc(orderId).delete();
      print('✅ Đơn hàng đã được xóa: $orderId');
    } catch (e) {
      print('❌ Lỗi xóa đơn hàng: $e');
      throw Exception('Lỗi xóa đơn hàng: $e');
    }
  }

  /// Lấy tất cả đơn hàng (admin only)
  Future<List<Order>> getAllOrders() async {
    try {
      final snapshot = await _firestore
          .collection(_ordersCollection)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Order.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('❌ Lỗi khi lấy tất cả đơn hàng: $e');
      return [];
    }
  }

  /// Thống kê đơn hàng theo trạng thái
  Future<Map<String, int>> getOrderStats() async {
    try {
      final snapshot =
          await _firestore.collection(_ordersCollection).get();

      final stats = <String, int>{
        'total': snapshot.docs.length,
        'pending': 0,
        'confirmed': 0,
        'shipped': 0,
        'delivered': 0,
        'cancelled': 0,
      };

      for (final doc in snapshot.docs) {
        final status = doc['status'] as String? ?? 'pending';
        if (stats.containsKey(status)) {
          stats[status] = (stats[status] ?? 0) + 1;
        }
      }

      return stats;
    } catch (e) {
      print('❌ Lỗi thống kê: $e');
      return {};
    }
  }

  /// Tính tổng doanh thu
  Future<double> getTotalRevenue() async {
    try {
      final snapshot = await _firestore
          .collection(_ordersCollection)
          .where('status', whereIn: ['delivered', 'confirmed'])
          .get();

      double total = 0;
      for (final doc in snapshot.docs) {
        total += (doc['totalPrice'] as num? ?? 0).toDouble();
      }

      return total;
    } catch (e) {
      print('❌ Lỗi tính doanh thu: $e');
      return 0;
    }
  }
}
