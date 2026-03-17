import '../models/product.dart';

/// A simple in-memory product provider for demo / initial work.
/// Replace this with real API calls as the app evolves.
class ProductService {
  static List<Product> getProducts() => _products;

  static final List<Product> _products = const [
    Product(
      id: 'p1',
      title: 'Classic Sneakers',
      description: 'Comfortable everyday sneakers with a modern look.',
      price: 59.99,
      imageUrl:
          'https://images.unsplash.com/photo-1528701800489-51b8c40aa4a9?auto=format&fit=crop&w=600&q=60',
    ),
    Product(
      id: 'p2',
      title: 'Sporty Watch',
      description: 'Water-resistant sports watch with multiple features.',
      price: 89.99,
      imageUrl:
          'https://images.unsplash.com/photo-1519741495011-049d6147be90?auto=format&fit=crop&w=600&q=60',
    ),
    Product(
      id: 'p3',
      title: 'Bluetooth Headphones',
      description: 'Noise-cancelling headphones with long battery life.',
      price: 129.99,
      imageUrl:
          'https://images.unsplash.com/photo-1519648023493-d82b5f8d7c3a?auto=format&fit=crop&w=600&q=60',
    ),
  ];
}
