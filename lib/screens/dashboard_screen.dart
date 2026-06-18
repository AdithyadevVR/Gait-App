import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/sensor_data.dart';
import '../services/connection_service.dart';
import '../theme/dashboard_theme.dart';
import '../widgets/foot_heatmap_widget.dart';
import '../widgets/foot_pressure_summary.dart';
import '../widgets/imu_panel.dart';
import '../widgets/metric_card.dart';
import '../widgets/sensor_data_card.dart';
import '../widgets/warnings_panel.dart';
import 'login_screen.dart';

class DashboardScreen extends StatefulWidget {
  final ConnectionService connectionService;

  const DashboardScreen({super.key, required this.connectionService});

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
        backgroundColor: DashboardTheme.surfaceDark,
        body: Container(
          decoration: const BoxDecoration(
            gradient: DashboardTheme.backgroundGradient,
          ),
          child: SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: StreamBuilder<SensorData>(
                    stream: widget.connectionService.dataStream,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) _latestData = snapshot.data;
                      if (_latestData == null) return _buildLoadingState();
                      return _buildDashboardContent(context, _latestData!);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white.withOpacity(0.9)),
            onPressed: _navigateBack,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Gait Analysis Dashboard',
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Real-time biomechanics monitoring',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
          _buildConnectionStatus(),
        ],
      ),
    );
  }

  Widget _buildConnectionStatus() {
    return StreamBuilder<ConnectionStatus>(
      stream: widget.connectionService.statusStream,
      builder: (context, snapshot) {
        final status = snapshot.data ?? ConnectionStatus.disconnected;
        final isWebSocket = widget.connectionService.currentType == ConnectionType.websocket;
        final displayType = isWebSocket ? 'WebSocket' : 'Serial';

        Color color;
        IconData icon;
        String statusText;

        switch (status) {
          case ConnectionStatus.connected:
            color = DashboardTheme.accentGreen;
            icon = isWebSocket ? Icons.wifi : Icons.usb;
            statusText = '$displayType Connected';
            break;
          case ConnectionStatus.connecting:
            color = DashboardTheme.accentYellow;
            icon = isWebSocket ? Icons.wifi_find : Icons.cable;
            statusText = 'Connecting...';
            break;
          case ConnectionStatus.error:
            color = DashboardTheme.accentRed;
            icon = Icons.error_outline;
            statusText = 'Connection Error';
            break;
          default:
            color = DashboardTheme.accentRed;
            icon = isWebSocket ? Icons.wifi_off : Icons.usb_off;
            statusText = '$displayType Disconnected';
        }
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: color.withOpacity(0.5)),
            boxShadow: status == ConnectionStatus.connected
                ? [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 0,
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 8),
              Text(
                statusText.toUpperCase(),
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: color,
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
          SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(DashboardTheme.accentCyan),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Waiting for sensor data...',
            style: GoogleFonts.inter(
              fontSize: 16,
              color: Colors.white.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardContent(BuildContext context, SensorData data) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 900;

        if (isWide) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildMainRow(data),
                const SizedBox(height: 20),
                _buildBottomRow(data),
                const SizedBox(height: 24),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildMainColumn(data),
              const SizedBox(height: 20),
              _buildBottomRow(data),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMainRow(SensorData data) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: _buildHeatmapCard('Left foot', data.leftHeelKg, data.leftBallKg, data.leftToeKg, false),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 3,
          child: _buildCenterMetrics(data),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 3,
          child: _buildHeatmapCard('Right foot', data.rightHeelKg, data.rightBallKg, data.rightToeKg, true),
        ),
      ],
    );
  }

  Widget _buildMainColumn(SensorData data) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildHeatmapCard('Left foot', data.leftHeelKg, data.leftBallKg, data.leftToeKg, false),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildHeatmapCard('Right foot', data.rightHeelKg, data.rightBallKg, data.rightToeKg, true),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildCenterMetrics(data),
      ],
    );
  }

  Widget _buildHeatmapCard(String title, double heel, double ball, double toe, bool isRight) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: DashboardTheme.glassCard(borderRadius: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 220,
            child: Center(
              child: AspectRatio(
                aspectRatio: 2 / 5,
                child: FootHeatmapWidget(
                  heelKg: heel,
                  ballKg: ball,
                  toeKg: toe,
                  isRightFoot: isRight,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCenterMetrics(SensorData data) {
    final avgCadence = (data.leftCadence + data.rightCadence) / 2;
    final leftPct = (data.leftPressurePercent * 100).round().clamp(0, 100);
    final rightPct = 100 - leftPct;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: DashboardTheme.glassCard(borderRadius: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Step count',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
              color: Colors.white.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: MetricCard(
                  label: 'Left steps',
                  value: '${data.leftSteps}',
                  icon: Icons.directions_walk,
                  accentColor: DashboardTheme.accentCyan,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: MetricCard(
                  label: 'Right steps',
                  value: '${data.rightSteps}',
                  icon: Icons.directions_walk,
                  accentColor: DashboardTheme.accentPurple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: MetricCard(
                  label: 'Cadence',
                  value: avgCadence.toStringAsFixed(0),
                  unit: 'spm',
                  icon: Icons.speed,
                  accentColor: DashboardTheme.accentGreen,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: MetricCard(
                  label: 'Step timing',
                  value: data.stepSymmetry.toStringAsFixed(2),
                  unit: 's diff',
                  icon: Icons.timelapse,
                  accentColor: DashboardTheme.accentYellow,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          MetricCard(
            label: 'Pressure balance',
            value: '$leftPct% L / $rightPct% R',
            accentColor: DashboardTheme.accentBlue,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomRow(SensorData data) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 700;
        if (isWide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: FootPressureSummary(
                  leftPressure: data.leftPressure,
                  rightPressure: data.rightPressure,
                  leftPressurePercent: data.leftPressurePercent,
                  rightPressurePercent: data.rightPressurePercent,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: WarningsPanel(warnings: data.gaitWarnings),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 3,
                child: ImuPanel(
                  pitch: data.pitchDeviation,
                  roll: data.rollDeviation,
                  ax: data.ax,
                  ay: data.ay,
                  az: data.az,
                  gx: data.gx,
                  gy: data.gy,
                  gz: data.gz,
                ),
              ),
            ],
          );
        }
        return Column(
          children: [
            FootPressureSummary(
              leftPressure: data.leftPressure,
              rightPressure: data.rightPressure,
              leftPressurePercent: data.leftPressurePercent,
              rightPressurePercent: data.rightPressurePercent,
            ),
            const SizedBox(height: 16),
            WarningsPanel(warnings: data.gaitWarnings),
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
          ],
        );
      },
    );
  }

  void _navigateBack() {
    widget.connectionService.disconnect();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => LoginScreen(
          connectionService: widget.connectionService,
        ),
      ),
    );
  }
}
