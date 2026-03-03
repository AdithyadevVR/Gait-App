import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/sensor_data.dart';

enum ConnectionStatus {
  disconnected,
  connecting,
  connected,
  error
}

class WebSocketService {
  WebSocketChannel? _channel;
  final StreamController<SensorData> _dataController = StreamController<SensorData>.broadcast();
  final StreamController<ConnectionStatus> _statusController = StreamController<ConnectionStatus>.broadcast();

  String? _url;
  Timer? _reconnectTimer;
  bool _isDisposed = false;

  Stream<SensorData> get dataStream => _dataController.stream;
  Stream<ConnectionStatus> get statusStream => _statusController.stream;

  void connect(String url) {
    _url = url;
    _isDisposed = false;
    _connectInternal();
  }

  void _connectInternal() {
    if (_url == null || _isDisposed) return;

    try {
      _statusController.add(ConnectionStatus.connecting);
      
      final  uri = Uri.parse(_url!);
      _channel = WebSocketChannel.connect(uri);
      
      _statusController.add(ConnectionStatus.connected);

      _channel?.stream.listen(
        (message) {
          try {
            print("RAW: $message");
            List<String> parts = message.toString().split(',');

            if (parts.length < 12) {
              print("Invalid packet length: ${parts.length}");
              return;
            }

            final data = SensorData.fromParts(parts);
            _dataController.add(data);
          } catch (e) {
            print('Error parsing sensor data: $e');
            // Depending on requirements, we could also emit an error state
          }
        },
        onDone: () {
          print('WebSocket closed');
          _handleDisconnect();
        },
        onError: (error) {
          print('WebSocket error: $error');
          _handleDisconnect();
        },
        cancelOnError: true,
      );
    } catch (e) {
      print('Connection failed: $e');
      _handleDisconnect();
    }
  }

  void _handleDisconnect() {
    if (_isDisposed) return;
    
    _statusController.add(ConnectionStatus.error);
    _channel?.sink.close();
    _channel = null;

    // Auto-reconnect after 3 seconds
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 3), () {
      print('Attempting to reconnect...');
      _connectInternal();
    });
  }

  void disconnect() {
    _isDisposed = true;
    _reconnectTimer?.cancel();
    _channel?.sink.close();
    _channel = null;
    _statusController.add(ConnectionStatus.disconnected);
  }

  void dispose() {
    disconnect();
    _dataController.close();
    _statusController.close();
  }
}
