import 'package:baibanhang/models/cart_item.dart';

class Order {
  const Order({
    required this.id,
    required this.items,
    required this.totalAmount,
    required this.createdAt,
  });

  final String id;
  final List<CartItem> items;
  final double totalAmount;
  final DateTime createdAt;
}
