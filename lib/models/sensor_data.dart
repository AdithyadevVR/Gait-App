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
