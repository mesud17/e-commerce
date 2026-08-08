import 'package:flutter/foundation.dart';

import '../models/user.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import 'cart_provider.dart';

enum AuthStatus {
  unknown,
  authenticated,
  unauthenticated,
}

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final StorageService _storageService = StorageService();

  final CartProvider _cartProvider;

  AuthProvider(this._cartProvider);

  AuthStatus _status = AuthStatus.unknown;
  User? _currentUser;
  String? _errorMessage;
  bool _isLoading = false;

  // GETTERS

  AuthStatus get status => _status;
  User? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isLoggedIn =>
      _status == AuthStatus.authenticated;

  // RESTORE SESSION

  Future<void> restoreSession() async {
    final token = await _storageService.getToken();
    final savedUser =
        await _storageService.getSavedUser();
    if (token != null && savedUser != null) {
      _currentUser = savedUser;
      _status = AuthStatus.authenticated;
      // Load the cart belonging to this user.
      await _cartProvider.setUser(
        savedUser.id,
      );
    } else {
      _status = AuthStatus.unauthenticated;

      // Make sure there is no active cart.
      _cartProvider.clearCurrentCart();
    }

    notifyListeners();
  }

  // LOGIN

  Future<bool> login(
    String username,
    String password,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      // 1. Login and receive token.
      final token = await _apiService.login(
        username,
        password,
      );

      // 2. Get the complete user information.
      final user =
          await _apiService.fetchUserByUsername(
        username,
      );

      // 3. Save authentication session.
      await _storageService.saveSession(
        token,
        user,
      );

      // 4. Update authentication state.
      _currentUser = user;
      _status = AuthStatus.authenticated;

      // 5. Load THIS USER'S cart.
      await _cartProvider.setUser(
        user.id,
      );

      _isLoading = false;

      notifyListeners();

      return true;
    } catch (e) {
      _errorMessage = e.toString();

      _status = AuthStatus.unauthenticated;

      _isLoading = false;

      notifyListeners();

      return false;
    }
  }

  // LOGOUT

  Future<void> logout() async {
    // Remove authentication information.
    await _storageService.clearSession();

    // Remove the current user's cart from memory.
    //
    // IMPORTANT:
    // This does NOT delete the user's saved cart.
    // If the same user logs in again, their cart will be restored.
    _cartProvider.clearCurrentCart();
    _currentUser = null;
    _status = AuthStatus.unauthenticated;
    _errorMessage = null;
    notifyListeners();
  }
}