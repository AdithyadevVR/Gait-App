import 'package:flutter/material.dart';
import '../services/connection_service.dart';
import '../services/serial_service.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  final ConnectionService connectionService;

  const LoginScreen({super.key, required this.connectionService});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _urlController = TextEditingController();
  bool _isConnecting = false;
  ConnectionType _connectionType = ConnectionType.websocket;

  @override
  void initState() {
    super.initState();
    _urlController.text = 'ws://10.92.181.145:81';

    // Listen to connection status
    widget.connectionService.statusStream.listen((status) {
      if (!mounted) return;

      if (status == ConnectionStatus.connecting) {
        setState(() => _isConnecting = true);
      } else if (status == ConnectionStatus.connected) {
        setState(() => _isConnecting = false);
        // Navigate to Dashboard
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => DashboardScreen(
              connectionService: widget.connectionService,
            ),
          ),
        );
      } else if (status == ConnectionStatus.error) {
        setState(() => _isConnecting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to connect. Please check the URL and your network.'),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        setState(() => _isConnecting = false);
      }
    });
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  void _connect() {
    widget.connectionService.setConnectionType(_connectionType);

    if (_connectionType == ConnectionType.websocket) {
      final url = _urlController.text.trim();
      if (url.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a WebSocket URL')),
        );
        return;
      }

      if (!url.startsWith('ws://') && !url.startsWith('wss://')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('URL must start with ws:// or wss://')),
        );
        return;
      }

      widget.connectionService.connect(url: url);
    } else {
      widget.connectionService.connect();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2C3E50), Color(0xFF3498DB)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.settings_input_antenna,
                        size: 80,
                        color: Color(0xFF3498DB),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Gait Analysis',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Connect to ESP32 Device',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                      const SizedBox(height: 32),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.all(4),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: _isConnecting ? null : () => setState(() => _connectionType = ConnectionType.websocket),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: _connectionType == ConnectionType.websocket ? Colors.white : Colors.transparent,
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: _connectionType == ConnectionType.websocket ? [const BoxShadow(color: Colors.black12, blurRadius: 4)] : null,
                                  ),
                                  alignment: Alignment.center,
                                  child: Text('WebSocket', style: TextStyle(fontWeight: FontWeight.bold, color: _connectionType == ConnectionType.websocket ? const Color(0xFF3498DB) : Colors.grey[600])),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: (_isConnecting || !isSerialSupported) ? null : () => setState(() => _connectionType = ConnectionType.serial),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: _connectionType == ConnectionType.serial ? Colors.white : Colors.transparent,
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: _connectionType == ConnectionType.serial ? [const BoxShadow(color: Colors.black12, blurRadius: 4)] : null,
                                  ),
                                  alignment: Alignment.center,
                                  child: Text('Serial', style: TextStyle(fontWeight: FontWeight.bold, color: _connectionType == ConnectionType.serial ? const Color(0xFF3498DB) : Colors.grey[600]?.withOpacity(isSerialSupported ? 1.0 : 0.5))),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextField(
                        controller: _urlController,
                        decoration: InputDecoration(
                          labelText: 'WebSocket URL',
                          hintText: 'ws://10.92.181.145:81',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.link),
                        ),
                        keyboardType: TextInputType.url,
                        enabled: !_isConnecting && _connectionType == ConnectionType.websocket,
                        onSubmitted: (_) => _connect(),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isConnecting ? null : _connect,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3498DB),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isConnecting
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  _connectionType == ConnectionType.serial ? 'CONNECT SERIAL DEVICE' : 'CONNECT',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
