import 'product.dart';

class CartItem {
  final String id;
  final Product product;
  final int quantity;
  final String? selectedSize;
  final String? selectedColor;

  CartItem({
    required this.id,
    required this.product,
    this.quantity = 1,
    this.selectedSize,
    this.selectedColor,
  });

  double getTotalPrice() {
    return product.price * quantity;
  }
}
