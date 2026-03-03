import 'package:flutter/material.dart';
import '../models/sensor_data.dart';
import '../services/websocket_service.dart';
import '../widgets/imu_card.dart';
import '../widgets/pressure_card.dart';
import 'login_screen.dart';

class DashboardScreen extends StatefulWidget {
  final WebSocketService webSocketService;

  const DashboardScreen({super.key, required this.webSocketService});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Add state to store latest data in case stream pauses
  SensorData? _latestData;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        widget.webSocketService.disconnect();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => LoginScreen(
              webSocketService: widget.webSocketService,
            ),
          ),
        );
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Real-Time Gait Data'),
          backgroundColor: Theme.of(context).primaryColor,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              widget.webSocketService.disconnect();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => LoginScreen(
                    webSocketService: widget.webSocketService,
                  ),
                ),
              );
            },
          ),
          actions: [
            StreamBuilder<ConnectionStatus>(
              stream: widget.webSocketService.statusStream,
              builder: (context, snapshot) {
                final status = snapshot.data ?? ConnectionStatus.disconnected;
                Color statusColor;
                IconData statusIcon;

                switch (status) {
                  case ConnectionStatus.connected:
                    statusColor = Colors.green;
                    statusIcon = Icons.wifi;
                    break;
                  case ConnectionStatus.connecting:
                    statusColor = Colors.orange;
                    statusIcon = Icons.wifi_find;
                    break;
                  case ConnectionStatus.disconnected:
                  case ConnectionStatus.error:
                  default:
                    statusColor = Colors.red;
                    statusIcon = Icons.wifi_off;
                    break;
                }

                return Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: Row(
                    children: [
                      Icon(statusIcon, color: statusColor),
                      const SizedBox(width: 8),
                      Text(
                        status.name.toUpperCase(),
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
        body: Container(
          color: Colors.grey[100],
          child: StreamBuilder<SensorData>(
            stream: widget.webSocketService.dataStream,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                _latestData = snapshot.data;
              }

              if (_latestData == null) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Waiting for sensor data...'),
                    ],
                  ),
                );
              }

              final data = _latestData!;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: PressureCard(
                            title: 'Left Foot',
                            heelKg: data.leftHeelKg,
                            ballKg: data.leftBallKg,
                            toeKg: data.leftToeKg,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: PressureCard(
                            title: 'Right Foot',
                            heelKg: data.rightHeelKg,
                            ballKg: data.rightBallKg,
                            toeKg: data.rightToeKg,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    ImuCard(
                      pitch: data.pitchDeviation,
                      roll: data.rollDeviation,
                      ax: data.ax,
                      ay: data.ay,
                      az: data.az,
                      gx: data.gx,
                      gy: data.gy,
                      gz: data.gz,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
