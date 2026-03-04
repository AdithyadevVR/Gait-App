import 'package:flutter/material.dart';
import '../models/sensor_data.dart';
import '../services/websocket_service.dart';
import '../widgets/foot_pressure_panel.dart';
import '../widgets/imu_panel.dart';
import '../widgets/gait_metrics_panel.dart';
import 'login_screen.dart';

class DashboardScreen extends StatefulWidget {
  final WebSocketService webSocketService;

  const DashboardScreen({super.key, required this.webSocketService});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  SensorData? _latestData;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _navigateBack();
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          elevation: 0,
          centerTitle: false,
          titleSpacing: 16,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Gait Analysis'),
              Text(
                'Real-time biomechanics dashboard',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _navigateBack,
          ),
          actions: [
            _buildConnectionStatus(),
          ],
        ),
        body: StreamBuilder<SensorData>(
          stream: widget.webSocketService.dataStream,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              _latestData = snapshot.data;
            }

            if (_latestData == null) {
              return _buildLoadingState();
            }

            return _buildDashboardContent(context, _latestData!);
          },
        ),
      ),
    );
  }

  void _navigateBack() {
    widget.webSocketService.disconnect();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => LoginScreen(
          webSocketService: widget.webSocketService,
        ),
      ),
    );
  }

  Widget _buildConnectionStatus() {
    return StreamBuilder<ConnectionStatus>(
      stream: widget.webSocketService.statusStream,
      builder: (context, snapshot) {
        final status = snapshot.data ?? ConnectionStatus.disconnected;
        Color statusColor;
        IconData statusIcon;

        switch (status) {
          case ConnectionStatus.connected:
            statusColor = Colors.greenAccent;
            statusIcon = Icons.wifi;
            break;
          case ConnectionStatus.connecting:
            statusColor = Colors.orangeAccent;
            statusIcon = Icons.wifi_find;
            break;
          case ConnectionStatus.disconnected:
          case ConnectionStatus.error:
          default:
            statusColor = Colors.redAccent;
            statusIcon = Icons.wifi_off;
            break;
        }

        return Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: Row(
            children: [
              Icon(statusIcon, color: statusColor, size: 20),
              const SizedBox(width: 8),
              Text(
                status.name.toUpperCase(),
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 24),
          Text(
            'Waiting for sensor data...',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardContent(BuildContext context, SensorData data) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isWideScreen = constraints.maxWidth > 800;

        if (isWideScreen) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 6,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: FootPressurePanel(
                              title: 'LEFT FOOT',
                              heelKg: data.leftHeelKg,
                              ballKg: data.leftBallKg,
                              toeKg: data.leftToeKg,
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            child: FootPressurePanel(
                              title: 'RIGHT FOOT',
                              heelKg: data.rightHeelKg,
                              ballKg: data.rightBallKg,
                              toeKg: data.rightToeKg,
                              isRightFoot: true,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      GaitMetricsPanel(
                        leftStepCount: data.leftSteps,
                        rightStepCount: data.rightSteps,
                        leftStepTime: data.leftStepTime,
                        rightStepTime: data.rightStepTime,
                        leftCadence: data.leftCadence,
                        rightCadence: data.rightCadence,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  flex: 4,
                  child: Column(
                    children: [
                      ImuPanel(
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
                ),
              ],
            ),
          );
        } else {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FootPressurePanel(
                  title: 'LEFT FOOT',
                  heelKg: data.leftHeelKg,
                  ballKg: data.leftBallKg,
                  toeKg: data.leftToeKg,
                ),
                const SizedBox(height: 16),
                FootPressurePanel(
                  title: 'RIGHT FOOT',
                  heelKg: data.rightHeelKg,
                  ballKg: data.rightBallKg,
                  toeKg: data.rightToeKg,
                  isRightFoot: true,
                ),
                const SizedBox(height: 16),
                GaitMetricsPanel(
                  leftStepCount: data.leftSteps,
                  rightStepCount: data.rightSteps,
                  leftStepTime: data.leftStepTime,
                  rightStepTime: data.rightStepTime,
                  leftCadence: data.leftCadence,
                  rightCadence: data.rightCadence,
                ),
                const SizedBox(height: 16),
                ImuPanel(
                  pitch: data.pitchDeviation,
                  roll: data.rollDeviation,
                  ax: data.ax,
                  ay: data.ay,
                  az: data.az,
                  gx: data.gx,
                  gy: data.gy,
                  gz: data.gz,
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
        }
      },
    );
  }
}
