import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../utils/constants.dart';

class WebSocketService {
  WebSocketChannel? _channel;
  late StreamController<Map<String, dynamic>> _controller;

  bool _isConnected = false;

  Stream<Map<String, dynamic>> get stream => _controller.stream;

  /// Connect to WebSocket
  void connect() {
    if (_isConnected) return;

    _controller = StreamController<Map<String, dynamic>>.broadcast();

    try {
      _channel = WebSocketChannel.connect(
        Uri.parse(AppConstants.wsUrl),
      );

      _isConnected = true;

      _channel!.stream.listen(
        (message) {
          try {
            final decoded = json.decode(message);

            // Ensure message is a JSON object
            if (decoded is Map<String, dynamic>) {
              _controller.add(decoded);
            }
          } catch (e) {
            // Ignore malformed messages
            print('WebSocket JSON parse error: $e');
          }
        },
        onError: (error) {
          print('WebSocket error: $error');
          disconnect();
        },
        onDone: () {
          print('WebSocket connection closed');
          disconnect();
        },
        cancelOnError: true,
      );
    } catch (e) {
      print('WebSocket connection failed: $e');
      disconnect();
    }
  }

  /// Disconnect and clean up
  void disconnect() {
    if (!_isConnected) return;

    _isConnected = false;
    _channel?.sink.close();
    _channel = null;

    if (!_controller.isClosed) {
      _controller.close();
    }
  }
}
