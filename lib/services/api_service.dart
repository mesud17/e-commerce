import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => message;
}

class ApiService {
  static const String _baseUrl = 'https://fakestoreapi.com';

  Future<List<Product>> fetchProducts() async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/products'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Product.fromJson(json)).toList();
      } else {
        throw ApiException('Server returned ${response.statusCode}');
      }
    } catch (e) {
      throw ApiException('Failed to load products: $e');
    }
  }


  Future<Product> fetchProductById(int id) async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/products/$id'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return Product.fromJson(jsonDecode(response.body));
      } else {
        throw ApiException('Server returned ${response.statusCode}');
      }
    } catch (e) {
      throw ApiException('Failed to load product: $e');
    }
  }

  Future<List<String>> fetchCategories() async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/products/categories'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => e.toString()).toList();
      } else {
        throw ApiException('Server returned ${response.statusCode}');
      }
    } catch (e) {
      throw ApiException('Failed to load categories: $e');
    }
  }

  Future<List<Product>> fetchProductsByCategory(String category) async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/products/category/$category'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Product.fromJson(json)).toList();
      } else {
        throw ApiException('Server returned ${response.statusCode}');
      }
    } catch (e) {
      throw ApiException('Failed to load category products: $e');
    }
  }
}