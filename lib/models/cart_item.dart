class CartItem {
  /// Unique id for the cart entry (e.g. "$productId-$selectedSize-$selectedColor").
  final String id;
  final String productId;
  final String title;
  final double price;
  final String imageUrl;
  final String selectedSize;
  final String selectedColor;
  final int quantity;
  final bool isChecked;

  const CartItem({
    required this.id,
    required this.productId,
    required this.title,
    required this.price,
    required this.imageUrl,
    required this.selectedSize,
    required this.selectedColor,
    this.quantity = 1,
    this.isChecked = false,
  });

  double get total => price * quantity;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'title': title,
      'price': price,
      'imageUrl': imageUrl,
      'selectedSize': selectedSize,
      'selectedColor': selectedColor,
      'quantity': quantity,
      'isChecked': isChecked,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] as String,
      productId: json['productId'] as String,
      title: json['title'] as String,
      price: (json['price'] as num).toDouble(),
      imageUrl: json['imageUrl'] as String,
      selectedSize: json['selectedSize'] as String,
      selectedColor: json['selectedColor'] as String,
      quantity: (json['quantity'] as num).toInt(),
      isChecked: json['isChecked'] as bool,
    );
  }
}
