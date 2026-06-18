import 'dart:async';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/sensor_data.dart';
import 'serial_service.dart';

enum ConnectionType { websocket, serial }

enum ConnectionStatus {
  disconnected,
  connecting,
  connected,
  error
}

class ConnectionService {
  ConnectionType _currentType = ConnectionType.websocket;
  ConnectionType get currentType => _currentType;

  final StreamController<SensorData> _dataController = StreamController<SensorData>.broadcast();
  final StreamController<ConnectionStatus> _statusController = StreamController<ConnectionStatus>.broadcast();

  Stream<SensorData> get dataStream => _dataController.stream;
  Stream<ConnectionStatus> get statusStream => _statusController.stream;

  // WebSocket members
  WebSocketChannel? _channel;
  String? _url;
  Timer? _reconnectTimer;
  bool _isDisposed = false;

  void setConnectionType(ConnectionType type) {
    _currentType = type;
  }

  void connect({String? url}) {
    _isDisposed = false;
    if (_currentType == ConnectionType.websocket) {
      if (url != null) _url = url;
      _connectWebSocket();
    } else {
      _connectSerial();
    }
  }

  void _connectWebSocket() {
    if (_url == null || _isDisposed) return;
    try {
      _statusController.add(ConnectionStatus.connecting);
      final uri = Uri.parse(_url!);
      _channel = WebSocketChannel.connect(uri);
      _statusController.add(ConnectionStatus.connected);

      _channel?.stream.listen(
        (message) => _parseAndEmit(message.toString()),
        onDone: _handleDisconnectWs,
        onError: (error) => _handleDisconnectWs(),
        cancelOnError: true,
      );
    } catch (e) {
      _handleDisconnectWs();
    }
  }

  void _handleDisconnectWs() {
    if (_isDisposed) return;
    _statusController.add(ConnectionStatus.error);
    _channel?.sink.close();
    _channel = null;

    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 3), () {
      _connectWebSocket();
    });
  }

  Future<void> _connectSerial() async {
    _statusController.add(ConnectionStatus.connecting);
    bool success = await connectSerial((line) {
      _parseAndEmit(line);
    }, () {
      if (!_isDisposed) {
        _statusController.add(ConnectionStatus.disconnected);
      }
    });

    if (!_isDisposed) {
      _statusController.add(success ? ConnectionStatus.connected : ConnectionStatus.error);
    }
  }

  void _parseAndEmit(String rawData) {
    try {
      List<String> parts = rawData.split(',');
      if (parts.length < 12) return;
      final data = SensorData.fromParts(parts);
      _dataController.add(data);
    } catch (e) {
      // Ignored parsing error
    }
  }

  void disconnect() {
    _isDisposed = true;
    _reconnectTimer?.cancel();
    _channel?.sink.close();
    _channel = null;
    disconnectSerial();
    _statusController.add(ConnectionStatus.disconnected);
  }

  void dispose() {
    disconnect();
    _dataController.close();
    _statusController.close();
  }
}
