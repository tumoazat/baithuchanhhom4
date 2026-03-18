import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/product.dart';

class ProductService {
  static const String _baseUrl = 'https://dummyjson.com/products';

  Future<List<Product>> fetchProducts({int limit = 10, int skip = 0}) async {
    final uri = Uri.parse('$_baseUrl?limit=$limit&skip=$skip');
    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load products. Status code: ${response.statusCode}',
      );
    }

    final Map<String, dynamic> data =
        jsonDecode(response.body) as Map<String, dynamic>;
    final List<dynamic> productsJson =
        (data['products'] as List<dynamic>?) ?? <dynamic>[];

    return productsJson
        .map((item) => Product.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<Product> fetchProductById(int id) async {
    final uri = Uri.parse('$_baseUrl/$id');
    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load product by id. Status code: ${response.statusCode}',
      );
    }

    final Map<String, dynamic> data =
        jsonDecode(response.body) as Map<String, dynamic>;
    return Product.fromJson(data);
  }
}
