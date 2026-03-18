import 'cart_item.dart';

class Order {
  final String id;
  final List<CartItem> items;
  final DateTime createdAt;
  final double totalAmount;

  const Order({
    required this.id,
    required this.items,
    required this.createdAt,
    required this.totalAmount,
  });
}
