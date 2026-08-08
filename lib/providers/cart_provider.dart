import 'package:flutter/foundation.dart';
import '../models/cart_item.dart';
import '../models/product.dart';
import '../services/storage_service.dart';

class CartProvider extends ChangeNotifier {
  final StorageService _storageService = StorageService();

  // Current user's cart
  final Map<int, CartItem> _items = {};

  // ID of the currently logged-in user
  int? _userId;

  bool _isLoaded = false;

  // GETTERS

  Map<int, CartItem> get items => _items;
  List<CartItem> get itemList => _items.values.toList();
  bool get isLoaded => _isLoaded;
  int? get userId => _userId;
  int get itemCount {
    return _items.values.fold(
      0,
      (sum, item) => sum + item.quantity,
    );
  }
  double get totalPrice {
    return _items.values.fold(
      0.0,
      (sum, item) => sum + item.subtotal,
    );
  }
  bool isInCart(int productId) {
    return _items.containsKey(productId);
  }
  int quantityOf(int productId) {
    return _items[productId]?.quantity ?? 0;
  }

  // SET USER

  Future<void> setUser(int userId) async {
    // If we're already using this user's cart,
    // there is nothing to do.
    if (_userId == userId && _isLoaded) {
      return;
    }

    _userId = userId;

    // Clear the cart currently held in memory.
    _items.clear();

    _isLoaded = false;

    notifyListeners();

    // Load this specific user's cart.
    final savedItems = await _storageService.loadCart(userId);
    for (final item in savedItems) {
      _items[item.product.id] = item;
    }
    _isLoaded = true;
    notifyListeners();
  }

  // CLEAR CURRENT USER'S CART

  Future<void> clearCart() async {
    if (_userId == null) {
      _items.clear();
      notifyListeners();
      return;
    }

    // Clear memory
    _items.clear();

    // Clear this user's saved cart
    await _storageService.clearCart(_userId!);
    notifyListeners();
  }

  // CLEAR CART FROM MEMORY ONLY

  void clearCurrentCart() {
    _items.clear();
    _isLoaded = false;
    notifyListeners();
  }

  // ADD TO CART

  Future<void> addToCart(Product product) async {
    if (_userId == null) {
      return;
    }

    if (_items.containsKey(product.id)) {
      _items[product.id]!.quantity += 1;
    } else {
      _items[product.id] = CartItem(
        product: product,
      );
    }

    notifyListeners();

    await _persist();
  }

  // REMOVE FROM CART

  Future<void> removeFromCart(int productId) async {
    if (_userId == null) {
      return;
    }
    if (_items.remove(productId) != null) {
      notifyListeners();
      await _persist();
    }
  }

  // INCREMENT

  Future<void> incrementQuantity(int productId) async {
    if (_userId == null) {
      return;
    }
    final item = _items[productId];
    if (item == null) {
      return;
    }
    item.quantity += 1;
    notifyListeners();
    await _persist();
  }

  // DECREMENT

  Future<void> decrementQuantity(int productId) async {
    if (_userId == null) {
      return;
    }
    final item = _items[productId];
    if (item == null) {
      return;
    }

    if (item.quantity > 1) {
      item.quantity -= 1;

      notifyListeners();

      await _persist();
    } else {
      await removeFromCart(productId);
    }
  }

  // SAVE CART

  Future<void> _persist() async {
    if (_userId == null) {
      return;
    }

    await _storageService.saveCart(
      _userId!,
      itemList,
    );
  }
}
