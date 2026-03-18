import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/cart_item.dart';
import '../models/product.dart';

class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  factory FirestoreService() {
    return _instance;
  }

  FirestoreService._internal();

  // ==================== Products Collection ====================
  /// Get all products
  Future<List<Product>> getAllProducts() async {
    try {
      final snapshot = await _db.collection('products').get();
      return snapshot.docs
          .map((doc) => Product.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch products: $e');
    }
  }

  /// Get products by category
  Future<List<Product>> getProductsByCategory(String category) async {
    try {
      final snapshot = await _db
          .collection('products')
          .where('category', isEqualTo: category)
          .get();
      return snapshot.docs
          .map((doc) => Product.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch products by category: $e');
    }
  }

  /// Search products by name or description
  Future<List<Product>> searchProducts(String query) async {
    try {
      final snapshot = await _db.collection('products').get();
      final lowerQuery = query.toLowerCase();
      return snapshot.docs
          .map((doc) => Product.fromFirestore(doc.data(), doc.id))
          .where((product) =>
              product.title.toLowerCase().contains(lowerQuery) ||
              product.description.toLowerCase().contains(lowerQuery))
          .toList();
    } catch (e) {
      throw Exception('Failed to search products: $e');
    }
  }

  /// Save a single product
  Future<void> saveProduct(Product product) async {
    try {
      await _db
          .collection('products')
          .doc(product.id)
          .set(product.toFirestore());
    } catch (e) {
      throw Exception('Failed to save product: $e');
    }
  }

  /// Delete a product
  Future<void> deleteProduct(String productId) async {
    try {
      await _db.collection('products').doc(productId).delete();
    } catch (e) {
      throw Exception('Failed to delete product: $e');
    }
  }

  // ==================== Orders Collection ====================
  /// Save user order
  Future<String> saveOrder(String userId, List<CartItem> items,
      double totalAmount, String status) async {
    try {
      final orderRef = await _db.collection('orders').add({
        'userId': userId,
        'items': items.map((item) => item.toJson()).toList(),
        'totalAmount': totalAmount,
        'status': status,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return orderRef.id;
    } catch (e) {
      throw Exception('Failed to save order: $e');
    }
  }

  /// Get user orders
  Future<List<Map<String, dynamic>>> getUserOrders(String userId) async {
    try {
      final snapshot = await _db
          .collection('orders')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          ...data,
          'createdAt': (data['createdAt'] as Timestamp?)?.toDate(),
          'updatedAt': (data['updatedAt'] as Timestamp?)?.toDate(),
        };
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch user orders: $e');
    }
  }

  /// Update order status
  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      await _db.collection('orders').doc(orderId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update order status: $e');
    }
  }

  // ==================== Cart Collection ====================
  /// Save user cart
  Future<void> saveUserCart(String userId, List<CartItem> items) async {
    try {
      await _db.collection('carts').doc(userId).set({
        'items': items.map((item) => item.toJson()).toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to save cart: $e');
    }
  }

  /// Get user cart
  Future<List<CartItem>> getUserCart(String userId) async {
    try {
      final doc = await _db.collection('carts').doc(userId).get();
      if (!doc.exists) return [];
      final items = doc.data()?['items'] as List?;
      if (items == null) return [];
      return (items)
          .whereType<Map<String, dynamic>>()
          .map(CartItem.fromJson)
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch user cart: $e');
    }
  }

  /// Clear user cart
  Future<void> clearUserCart(String userId) async {
    try {
      await _db.collection('carts').doc(userId).delete();
    } catch (e) {
      throw Exception('Failed to clear cart: $e');
    }
  }

  // ==================== User Profiles ====================
  /// Save user profile
  Future<void> saveUserProfile(String userId, Map<String, dynamic> userData) async {
    try {
      await _db.collection('users').doc(userId).set(
        {
          ...userData,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    } catch (e) {
      throw Exception('Failed to save user profile: $e');
    }
  }

  /// Get user profile
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final doc = await _db.collection('users').doc(userId).get();
      if (!doc.exists) return null;
      return doc.data();
    } catch (e) {
      throw Exception('Failed to fetch user profile: $e');
    }
  }

  // ==================== Wishlist ====================
  /// Add item to wishlist
  Future<void> addToWishlist(String userId, String productId) async {
    try {
      await _db
          .collection('wishlists')
          .doc(userId)
          .collection('items')
          .doc(productId)
          .set({
        'productId': productId,
        'addedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to add to wishlist: $e');
    }
  }

  /// Remove item from wishlist
  Future<void> removeFromWishlist(String userId, String productId) async {
    try {
      await _db
          .collection('wishlists')
          .doc(userId)
          .collection('items')
          .doc(productId)
          .delete();
    } catch (e) {
      throw Exception('Failed to remove from wishlist: $e');
    }
  }

  /// Get user wishlist
  Future<List<String>> getUserWishlist(String userId) async {
    try {
      final snapshot = await _db
          .collection('wishlists')
          .doc(userId)
          .collection('items')
          .get();
      return snapshot.docs.map((doc) => doc.id).toList();
    } catch (e) {
      throw Exception('Failed to fetch wishlist: $e');
    }
  }
}
