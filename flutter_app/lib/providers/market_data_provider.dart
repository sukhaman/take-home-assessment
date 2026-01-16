import 'dart:async';
import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../services/websocket_service.dart';
import '../models/market_data_model.dart';

class MarketDataProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final WebSocketService _wsService = WebSocketService();

  StreamSubscription? _wsSubscription;

  List<MarketData> _marketData = [];
  bool _isLoading = false;
  bool _isRefreshing = false;
  String? _error;

  List<MarketData> get marketData => _marketData;
  bool get isLoading => _isLoading;
  bool get isRefreshing => _isRefreshing;
  String? get error => _error;

  /// Initial load + pull-to-refresh
  Future<void> loadMarketData({bool refresh = false}) async {
    if (refresh) {
      _isRefreshing = true;
    } else {
      _isLoading = true;
      _error = null;
    }
    notifyListeners();

    try {
      final data = await _apiService.getMarketData();
      _marketData = data.map((json) => MarketData.fromJson(json)).toList();

      // Start WebSocket AFTER initial data is available
      _startWebSocket();
    } catch (e) {
      _error = 'Failed to load market data: $e';
      if (!refresh) _marketData = [];
    } finally {
      _isLoading = false;
      _isRefreshing = false;
      notifyListeners();
    }
  }

  /// Listen to WebSocket stream
  void _startWebSocket() {
    _wsService.connect();

    _wsSubscription?.cancel();
    _wsSubscription = _wsService.stream.listen((data) {
      _updateMarketDataFromSocket(data);
    });
  }

  /// Update existing market item (no list rebuild)
  void _updateMarketDataFromSocket(Map<String, dynamic> message) {
    if (message['type'] != 'market_update') return;
    final data = message['data'];
    if (data == null) return;

    final updated = MarketData(
      symbol: data['symbol'],
      price: double.tryParse(data['price'].toString()) ?? 0,
      change24h: double.tryParse(data['change24h'].toString()) ?? 0,
      changePercent24h:
          double.tryParse(data['changePercent24h']?.toString() ?? '0') ?? 0,
      volume: double.tryParse(data['volume'].toString()) ?? 0,
    );

    final index =
        _marketData.indexWhere((item) => item.symbol == updated.symbol);
    if (index != -1) {
      _marketData = _marketData.map((item) {
        return item.symbol == updated.symbol ? updated : item;
      }).toList();

      notifyListeners();
    }
  }

  @override
  void dispose() {
    _wsSubscription?.cancel();
    _wsService.disconnect();
    super.dispose();
  }
}
