import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';
import '../models/user.dart';

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => message;
}

class ApiService {
  static const String _baseUrl = 'https://fakestoreapi.com';

  // PRODUCTS

  Future<List<Product>> fetchProducts() async {
    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl/products'),
          )
          .timeout(
            const Duration(seconds: 10),
          );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        return data
            .map((json) => Product.fromJson(json))
            .toList();
      } else {
        throw ApiException(
          'Server returned ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }

      throw ApiException(
        'Failed to load products: $e',
      );
    }
  }

  // SINGLE PRODUCT

  Future<Product> fetchProductById(int id) async {
    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl/products/$id'),
          )
          .timeout(
            const Duration(seconds: 10),
          );

      if (response.statusCode == 200) {
        return Product.fromJson(
          jsonDecode(response.body),
        );
      } else {
        throw ApiException(
          'Server returned ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }

      throw ApiException(
        'Failed to load product: $e',
      );
    }
  }

  // CATEGORIES

  Future<List<String>> fetchCategories() async {
    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl/products/categories'),
          )
          .timeout(
            const Duration(seconds: 10),
          );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        return data
            .map((e) => e.toString())
            .toList();
      } else {
        throw ApiException(
          'Server returned ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }

      throw ApiException(
        'Failed to load categories: $e',
      );
    }
  }

  // PRODUCTS BY CATEGORY

  Future<List<Product>> fetchProductsByCategory(
    String category,
  ) async {
    try {
      final response = await http
          .get(
            Uri.parse(
              '$_baseUrl/products/category/$category',
            ),
          )
          .timeout(
            const Duration(seconds: 10),
          );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        return data
            .map((json) => Product.fromJson(json))
            .toList();
      } else {
        throw ApiException(
          'Server returned ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }

      throw ApiException(
        'Failed to load category products: $e',
      );
    }
  }

  // LOGIN

  Future<String> login(
    String username,
    String password,
  ) async {
    try {
      print('============================');
      print('Starting login...');
      print('Username: $username');
      print('============================');

      final response = await http
          .post(
            Uri.parse('$_baseUrl/auth/login'),
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'username': username,
              'password': password,
            }),
          )
          .timeout(
            const Duration(seconds: 10),
          );

      print('Login response status: ${response.statusCode}');
      print('Login response body: ${response.body}');

      // FakeStoreAPI can return 200 or 201 for a successful login.
      if (response.statusCode == 200 ||
          response.statusCode == 201) {
        final Map<String, dynamic> data =
            jsonDecode(response.body);

        final token = data['token'];

        if (token == null || token is! String) {
          throw ApiException(
            'Login succeeded, but no token was returned.',
          );
        }

        print('Login successful!');
        print('Token received.');

        return token;
      }

      // 401 or other unsuccessful response
      throw ApiException(
        'Invalid username or password.',
      );
    } catch (e) {
      print('LOGIN ERROR: $e');

      if (e is ApiException) {
        rethrow;
      }

      throw ApiException(
        'Login failed: $e',
      );
    }
  }

  // GET USER BY ID

  Future<User> fetchUserById(int id) async {
    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl/users/$id'),
          )
          .timeout(
            const Duration(seconds: 10),
          );

      if (response.statusCode == 200) {
        return User.fromJson(
          jsonDecode(response.body),
        );
      } else {
        throw ApiException(
          'Server returned ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }

      throw ApiException(
        'Failed to load user: $e',
      );
    }
  }

  // GET USER BY USERNAME

  Future<User> fetchUserByUsername(
    String username,
  ) async {
    try {
      print('============================');
      print('Fetching user...');
      print('Username: $username');
      print('============================');

      final response = await http
          .get(
            Uri.parse('$_baseUrl/users'),
          )
          .timeout(
            const Duration(seconds: 10),
          );

      print('Users response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data =
            jsonDecode(response.body);

        Map<String, dynamic>? matchingUser;

        for (final userEntry in data) {
          if (userEntry is Map<String, dynamic> &&
              userEntry['username'] == username) {
            matchingUser = userEntry;
            break;
          }
        }

        if (matchingUser == null) {
          throw ApiException(
            'User not found.',
          );
        }

        print('User found: $username');

        return User.fromJson(matchingUser);
      } else {
        throw ApiException(
          'Server returned ${response.statusCode}',
        );
      }
    } catch (e) {
      print('USER ERROR: $e');

      if (e is ApiException) {
        rethrow;
      }

      throw ApiException(
        'Failed to load user: $e',
      );
    }
  }
}