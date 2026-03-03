import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'services/websocket_service.dart';

void main() {
  runApp(const GaitApp());
}

class GaitApp extends StatefulWidget {
  const GaitApp({super.key});

  @override
  State<GaitApp> createState() => _GaitAppState();
}

class _GaitAppState extends State<GaitApp> {
  late final WebSocketService _webSocketService;

  @override
  void initState() {
    super.initState();
    _webSocketService = WebSocketService();
  }

  @override
  void dispose() {
    _webSocketService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gait Analysis App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3498DB)),
        useMaterial3: true,
        fontFamily: 'Inter',
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),
      ),
      home: LoginScreen(webSocketService: _webSocketService),
    );
  }
}
