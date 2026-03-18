import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _usersCollection = 'users';

  /// Lưu hoặc cập nhật thông tin người dùng vào Firestore
  Future<void> saveOrUpdateUser({
    required String uid,
    required String email,
    String? displayName,
    String? photoUrl,
    String? phone,
  }) async {
    try {
      await _firestore.collection(_usersCollection).doc(uid).set(
        {
          'uid': uid,
          'email': email,
          'displayName': displayName ?? 'Anonymous',
          'photoUrl': photoUrl,
          'phone': phone,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'status': 'active',
        },
        SetOptions(merge: true),
      );
      print('✅ Người dùng đã được lưu: $email (UID: $uid)');
    } catch (e) {
      print('❌ Lỗi khi lưu người dùng: $e');
      throw Exception('Lỗi lưu thông tin người dùng: $e');
    }
  }

  /// Lấy thông tin người dùng từ Firestore
  Future<Map<String, dynamic>?> getUser(String uid) async {
    try {
      final doc = await _firestore.collection(_usersCollection).doc(uid).get();
      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      print('❌ Lỗi khi lấy thông tin người dùng: $e');
      return null;
    }
  }

  /// Xóa người dùng
  Future<void> deleteUser(String uid) async {
    try {
      await _firestore.collection(_usersCollection).doc(uid).delete();
      print('✅ Người dùng đã được xóa: $uid');
    } catch (e) {
      print('❌ Lỗi khi xóa người dùng: $e');
      throw Exception('Lỗi xóa người dùng: $e');
    }
  }

  /// Lấy danh sách tất cả người dùng (cho admin)
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      final snapshot = await _firestore.collection(_usersCollection).get();
      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('❌ Lỗi khi lấy danh sách người dùng: $e');
      return [];
    }
  }

  /// Cập nhật profile người dùng
  Future<void> updateUserProfile({
    required String uid,
    String? displayName,
    String? phone,
    String? photoUrl,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (displayName != null) updateData['displayName'] = displayName;
      if (phone != null) updateData['phone'] = phone;
      if (photoUrl != null) updateData['photoUrl'] = photoUrl;

      await _firestore
          .collection(_usersCollection)
          .doc(uid)
          .update(updateData);
      print('✅ Profile người dùng đã được cập nhật: $uid');
    } catch (e) {
      print('❌ Lỗi cập nhật profile: $e');
      throw Exception('Lỗi cập nhật profile: $e');
    }
  }

  /// Kiểm tra người dùng đã tồn tại chưa
  Future<bool> userExists(String uid) async {
    try {
      final doc = await _firestore.collection(_usersCollection).doc(uid).get();
      return doc.exists;
    } catch (e) {
      print('❌ Lỗi kiểm tra người dùng: $e');
      return false;
    }
  }
}
