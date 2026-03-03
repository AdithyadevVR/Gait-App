import 'package:flutter/material.dart';
import '../services/websocket_service.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  final WebSocketService webSocketService;

  const LoginScreen({super.key, required this.webSocketService});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _urlController = TextEditingController();
  bool _isConnecting = false;

  @override
  void initState() {
    super.initState();
    _urlController.text = 'ws://10.92.181.145:81';

    // Listen to connection status
    widget.webSocketService.statusStream.listen((status) {
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
              webSocketService: widget.webSocketService,
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

    widget.webSocketService.connect(url);
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
                        enabled: !_isConnecting,
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
                              : const Text(
                                  'CONNECT',
                                  style: TextStyle(
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
