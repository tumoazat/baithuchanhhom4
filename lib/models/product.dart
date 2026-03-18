class Product {
  final String id;
  final String name;
  final double price;
  final double? originalPrice;
  final String description;
  final List<String> images;
  final List<String>? sizes;
  final List<String>? colors;
  final double rating;
  final int reviews;
  final int stock;

  Product({
    required this.id,
    required this.name,
    required this.price,
    this.originalPrice,
    required this.description,
    required this.images,
    this.sizes,
    this.colors,
    this.rating = 0.0,
    this.reviews = 0,
    this.stock = 0,
  });

  // Convenience method to get discount percentage if original price exists
  int? getDiscountPercentage() {
    if (originalPrice == null || originalPrice! <= 0 || price >= originalPrice!) {
      return null;
    }
    return ((originalPrice! - price) / originalPrice! * 100).toInt();
  }
}
