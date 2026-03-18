import 'package:baibanhang/models/cart_item.dart';

class Order {
  final String? id;
  final List<CartItem>? items;
  final DateTime? createdAt;
  final double? totalPrice;
  final String? status;
  final String? deliveryAddress;
  final String? phoneNumber;
  final String? paymentMethod;
  final String? notes;

  const Order({
    this.id,
    this.items,
    this.createdAt,
    this.totalPrice,
    this.status = 'pending',
    this.deliveryAddress,
    this.phoneNumber,
    this.paymentMethod = 'COD',
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'items': items?.map((item) => item.toJson()).toList(),
      'createdAt': createdAt?.toIso8601String(),
      'totalPrice': totalPrice,
      'status': status,
      'deliveryAddress': deliveryAddress,
      'phoneNumber': phoneNumber,
      'paymentMethod': paymentMethod,
      'notes': notes,
    };
  }

  static Order fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as String?,
      items: (json['items'] as List<dynamic>?)
          ?.map((item) => CartItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      totalPrice: (json['totalPrice'] as num?)?.toDouble(),
      status: json['status'] as String?,
      deliveryAddress: json['deliveryAddress'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      paymentMethod: json['paymentMethod'] as String?,
      notes: json['notes'] as String?,
    );
  }

  static Order fromFirestore(Map<String, dynamic> data, String docId) {
    return Order(
      id: docId,
      items: (data['items'] as List<dynamic>?)
          ?.map((item) => CartItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as dynamic).toDate()
          : null,
      totalPrice: (data['totalPrice'] as num?)?.toDouble(),
      status: data['status'] as String?,
      deliveryAddress: data['deliveryAddress'] as String?,
      phoneNumber: data['phoneNumber'] as String?,
      paymentMethod: data['paymentMethod'] as String?,
      notes: data['notes'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'items': items?.map((item) => item.toJson()).toList(),
      'totalPrice': totalPrice,
      'status': status,
      'deliveryAddress': deliveryAddress,
      'phoneNumber': phoneNumber,
      'paymentMethod': paymentMethod,
      'notes': notes,
    };
  }
}
