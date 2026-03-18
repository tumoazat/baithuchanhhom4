class Product {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  final String category;
  final int stock;
  final double rating;
  final int reviewCount;

  const Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.category = 'Tat ca',
    this.stock = 100,
    this.rating = 0.0,
    this.reviewCount = 0,
  });

  /// Create Product from Firestore document
  factory Product.fromFirestore(Map<String, dynamic> data, String docId) {
    return Product(
      id: docId,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      imageUrl: data['imageUrl'] ?? '',
      category: data['category'] ?? 'Tat ca',
      stock: data['stock'] ?? 100,
      rating: (data['rating'] ?? 0).toDouble(),
      reviewCount: data['reviewCount'] ?? 0,
    );
  }

  /// Convert Product to Firestore document map
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'category': category,
      'stock': stock,
      'rating': rating,
      'reviewCount': reviewCount,
    };
  }

  /// Convert Product to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      ...toFirestore(),
    };
  }

  /// Create Product from JSON
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      imageUrl: json['imageUrl'] ?? '',
      category: json['category'] ?? 'Tat ca',
      stock: json['stock'] ?? 100,
      rating: (json['rating'] ?? 0).toDouble(),
      reviewCount: json['reviewCount'] ?? 0,
    );
  }
}
