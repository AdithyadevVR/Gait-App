import 'dart:math' as math;

class SensorData {
  final double leftHeelKg;
  final double leftBallKg;
  final double leftToeKg;
  final double rightHeelKg;
  final double rightBallKg;
  final double rightToeKg;

  final double ax;
  final double ay;
  final double az;

  final double gx;
  final double gy;
  final double gz;

  final int leftSteps;
  final int rightSteps;
  final double leftStepTime;
  final double rightStepTime;
  final double leftCadence;
  final double rightCadence;

  SensorData({
    required this.leftHeelKg,
    required this.leftBallKg,
    required this.leftToeKg,
    required this.rightHeelKg,
    required this.rightBallKg,
    required this.rightToeKg,
    required this.ax,
    required this.ay,
    required this.az,
    required this.gx,
    required this.gy,
    required this.gz,
    required this.leftSteps,
    required this.rightSteps,
    required this.leftStepTime,
    required this.rightStepTime,
    required this.leftCadence,
    required this.rightCadence,
  });

  // Calculate pitch deviation (Forward Tilt)
  double get pitchDeviation {
    // pitch = atan2(Ax, sqrt(Ay^2 + Az^2)) * (180 / pi)
    return math.atan2(ax, math.sqrt(ay * ay + az * az)) * (180 / math.pi);
  }

  // Calculate roll deviation (Side Tilt)
  double get rollDeviation {
    // roll = atan2(Ay, sqrt(Ax^2 + Az^2)) * (180 / pi)
    return math.atan2(ay, math.sqrt(ax * ax + az * az)) * (180 / math.pi);
  }

  // --- Foot pressure (total per foot) ---
  double get leftPressure => leftHeelKg + leftBallKg + leftToeKg;
  double get rightPressure => rightHeelKg + rightBallKg + rightToeKg;

  double get totalPressure => leftPressure + rightPressure;

  // Pressure distribution percentage (0..1); 0.5 each if total is 0
  double get leftPressurePercent =>
      totalPressure > 0 ? leftPressure / totalPressure : 0.5;
  double get rightPressurePercent =>
      totalPressure > 0 ? rightPressure / totalPressure : 0.5;

  // --- Heel / ball / toe ratios per foot (0..1) ---
  double get leftHeelRatio =>
      leftPressure > 0 ? leftHeelKg / leftPressure : 0;
  double get leftBallRatio =>
      leftPressure > 0 ? leftBallKg / leftPressure : 0;
  double get leftToeRatio =>
      leftPressure > 0 ? leftToeKg / leftPressure : 0;

  double get rightHeelRatio =>
      rightPressure > 0 ? rightHeelKg / rightPressure : 0;
  double get rightBallRatio =>
      rightPressure > 0 ? rightBallKg / rightPressure : 0;
  double get rightToeRatio =>
      rightPressure > 0 ? rightToeKg / rightPressure : 0;

  // --- Step symmetry (timing difference in seconds) ---
  double get stepSymmetry => (leftStepTime - rightStepTime).abs();

  // --- Cadence difference (steps/min) ---
  double get cadenceDiff => (leftCadence - rightCadence).abs();

  // --- Gait warnings (thresholds: 60% overload, heel > 0.7, toe > 0.6, step sym > 0.2s, cadence diff > 10) ---
  List<String> get gaitWarnings {
    final list = <String>[];
    if (leftPressurePercent > 0.60) list.add('Left Foot Overloading');
    if (rightPressurePercent > 0.60) list.add('Right Foot Overloading');
    if (leftHeelRatio > 0.7 || rightHeelRatio > 0.7) list.add('Heel Dominant Strike');
    if (leftToeRatio > 0.6 || rightToeRatio > 0.6) list.add('Forefoot Dominant Strike');
    if (stepSymmetry > 0.2) list.add('Uneven Step Timing');
    if (cadenceDiff > 10) list.add('Cadence Imbalance');
    return list;
  }

  // Helper function to convert ADC to KG
  static double _adcToKg(double adc) {
    return (adc / 4095.0) * 20.0;
  }

  factory SensorData.fromParts(List<String> parts) {
    double leftHeel  = double.tryParse(parts[0].trim()) ?? 0;
    double leftBall  = double.tryParse(parts[1].trim()) ?? 0;
    double leftToe   = double.tryParse(parts[2].trim()) ?? 0;
    double rightHeel = double.tryParse(parts[3].trim()) ?? 0;
    double rightBall = double.tryParse(parts[4].trim()) ?? 0;
    double rightToe  = double.tryParse(parts[5].trim()) ?? 0;
    double ax        = double.tryParse(parts[6].trim()) ?? 0;
    double ay        = double.tryParse(parts[7].trim()) ?? 0;
    double az        = double.tryParse(parts[8].trim()) ?? 0;
    double gx        = double.tryParse(parts[9].trim()) ?? 0;
    double gy        = double.tryParse(parts[10].trim()) ?? 0;
    double gz        = double.tryParse(parts[11].trim()) ?? 0;

    // Optional extended gait metrics, if present in the packet
    int leftSteps       = parts.length > 12 ? int.tryParse(parts[12].trim()) ?? 0 : 0;
    int rightSteps      = parts.length > 13 ? int.tryParse(parts[13].trim()) ?? 0 : 0;
    double leftStepTime = parts.length > 14 ? double.tryParse(parts[14].trim()) ?? 0 : 0;
    double rightStepTime= parts.length > 15 ? double.tryParse(parts[15].trim()) ?? 0 : 0;
    double leftCadence  = parts.length > 16 ? double.tryParse(parts[16].trim()) ?? 0 : 0;
    double rightCadence = parts.length > 17 ? double.tryParse(parts[17].trim()) ?? 0 : 0;

    print('RightHeel parsed: ' + rightHeel.toString());
    print('RightBall parsed: ' + rightBall.toString());

    return SensorData(
      leftHeelKg: _adcToKg(leftHeel),
      leftBallKg: _adcToKg(leftBall),
      leftToeKg: _adcToKg(leftToe),
      rightHeelKg: _adcToKg(rightHeel),
      rightBallKg: _adcToKg(rightBall),
      rightToeKg: _adcToKg(rightToe),
      ax: ax,
      ay: ay,
      az: az,
      gx: gx,
      gy: gy,
      gz: gz,
      leftSteps: leftSteps,
      rightSteps: rightSteps,
      leftStepTime: leftStepTime,
      rightStepTime: rightStepTime,
      leftCadence: leftCadence,
      rightCadence: rightCadence,
    );
  }
}
