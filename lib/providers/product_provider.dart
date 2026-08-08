import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../services/api_service.dart';

enum LoadStatus { initial, loading, loaded, error }

class ProductProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Product> _allProducts = [];
  List<String> _categories = [];
  String _selectedCategory = 'All';
  String _searchQuery = '';
  LoadStatus _status = LoadStatus.initial;
  String _errorMessage = '';

  List<String> get categories => ['All', ..._categories];
  String get selectedCategory => _selectedCategory;
  LoadStatus get status => _status;
  String get errorMessage => _errorMessage;

  List<Product> get filteredProducts {
    var result = _allProducts;

    if (_selectedCategory != 'All') {
      result = result.where((p) => p.category == _selectedCategory).toList();
    }

    if (_searchQuery.trim().isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      result = result.where((p) => p.title.toLowerCase().contains(query)).toList();
    }

    return result;
  }

  Future<void> loadProducts() async {
    _status = LoadStatus.loading;
    notifyListeners();

    try {
      final results = await Future.wait([
        _apiService.fetchProducts(),
        _apiService.fetchCategories(),
      ]);
      _allProducts = results[0] as List<Product>;
      _categories = results[1] as List<String>;
      _status = LoadStatus.loaded;
    } catch (e) {
      _errorMessage = e.toString();
      _status = LoadStatus.error;
    }
    notifyListeners();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }
}