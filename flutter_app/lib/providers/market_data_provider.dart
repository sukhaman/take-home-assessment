import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../models/market_data_model.dart';

class MarketDataProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<MarketData> _marketData = [];
  bool _isLoading = false; // Initial full-screen load
  bool _isRefreshing = false; // Pull-to-refresh
  String? _error;

  List<MarketData> get marketData => _marketData;
  bool get isLoading => _isLoading;
  bool get isRefreshing => _isRefreshing;
  String? get error => _error;

  /// Load market data (full-screen loading)
  Future<void> loadMarketData({bool refresh = false}) async {
    if (refresh) {
      _isRefreshing = true; // Pull-to-refresh
    } else {
      _isLoading = true; // Initial load
      _error = null;
    }
    notifyListeners();

    try {
      final data = await _apiService.getMarketData();
      _marketData = data.map((json) => MarketData.fromJson(json)).toList();
    } catch (e) {
      _error = 'Failed to load market data: $e';
      if (!refresh) _marketData = [];
    } finally {
      _isLoading = false;
      _isRefreshing = false;
      notifyListeners();
    }
  }
}
