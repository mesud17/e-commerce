import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cart_item.dart';
import '../models/product.dart';
import '../models/user.dart';

class StorageService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'current_user';

  // CART KEY

  String _cartKey(int userId) {
    return 'cart_items_user_$userId';
  }

  // SAVE CART

  Future<void> saveCart(
    int userId,
    List<CartItem> items,
  ) async {
    final prefs =
        await SharedPreferences.getInstance();

    final encoded = jsonEncode(
      items.map(
        (item) {
          return {
            'product': {
              'id': item.product.id,
              'title': item.product.title,
              'price': item.product.price,
              'description': item.product.description,
              'category': item.product.category,
              'image': item.product.image,
              'rating': {
                'rate': item.product.rating,
                'count': item.product.ratingCount,
              },
            },
            'quantity': item.quantity,
          };
        },
      ).toList(),
    );

    await prefs.setString(
      _cartKey(userId),
      encoded,
    );
  }

  // LOAD CART

  Future<List<CartItem>> loadCart(int userId) async {
    final prefs =
        await SharedPreferences.getInstance();

    final raw = prefs.getString(
      _cartKey(userId),
    );

    if (raw == null) {
      return [];
    }

    try {
      final List<dynamic> decoded =
          jsonDecode(raw);

      return decoded.map(
        (entry) {
          final productJson =
              entry['product']
                  as Map<String, dynamic>;

          final quantityValue =
              entry['quantity'];

          return CartItem(
            product:
                Product.fromJson(productJson),

            quantity: quantityValue is int
                ? quantityValue
                : int.tryParse(
                      '$quantityValue',
                    ) ??
                    1,
          );
        },
      ).toList();
    } catch (_) {
      return [];
    }
  }

  // CLEAR CART

  Future<void> clearCart(int userId) async {
    final prefs =
        await SharedPreferences.getInstance();

    await prefs.remove(
      _cartKey(userId),
    );
  }

  // SAVE SESSION

  Future<void> saveSession(
    String token,
    User user,
  ) async {
    final prefs =
        await SharedPreferences.getInstance();

    await prefs.setString(
      _tokenKey,
      token,
    );

    await prefs.setString(
      _userKey,
      jsonEncode(user.toJson()),
    );
  }

  // GET TOKEN

  Future<String?> getToken() async {
    final prefs =
        await SharedPreferences.getInstance();

    return prefs.getString(_tokenKey);
  }

  // ============================================================
  // GET SAVED USER
  // ============================================================

  Future<User?> getSavedUser() async {
    final prefs =
        await SharedPreferences.getInstance();

    final raw =
        prefs.getString(_userKey);

    if (raw == null) {
      return null;
    }

    try {
      return User.fromJson(
        jsonDecode(raw),
      );
    } catch (_) {
      return null;
    }
  }

  // CLEAR SESSION

  Future<void> clearSession() async {
    final prefs =
        await SharedPreferences.getInstance();

    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }
}