import 'package:app_ban_hang/models/cart_item.dart';

class Order {
  final String id;
  final List<CartItem> items;
  final double totalAmount;
  final String status;
  final DateTime createdAt;
  final String? address;

  Order({
    required this.id,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
    this.address,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'items': items.map((item) => item.toJson()).toList(),
      'totalAmount': totalAmount,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'address': address,
    };
  }

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: (json['id'] ?? '').toString(),
      items: (json['items'] as List<dynamic>? ?? const [])
          .map(
            (item) => CartItem.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList(),
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0,
      status: (json['status'] ?? 'pending').toString(),
      createdAt: DateTime.tryParse((json['createdAt'] ?? '').toString()) ??
          DateTime.now(),
      address: json['address']?.toString(),
    );
  }
}
