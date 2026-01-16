import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class ApiService {
  static const String baseUrl = AppConstants.baseUrl;

  /// Fetches market data from the API
  /// Returns a list of maps representing market items
  /// Throws an exception if the API call fails
  Future<List<Map<String, dynamic>>> getMarketData() async {
    final url = Uri.parse('$baseUrl${AppConstants.marketDataEndpoint}');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        // The API returns { "success": true, "data": [...] }
        return List<Map<String, dynamic>>.from(jsonData['data']);
      } else {
        throw Exception(
            'Failed to load market data: ${response.statusCode} ${response.reasonPhrase}');
      }
    } catch (e) {
      // Re-throw to allow the UI to handle errors
      throw Exception('Error fetching market data: $e');
    }
  }
}
