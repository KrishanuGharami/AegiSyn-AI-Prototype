class TelemetryPoint {
  final DateTime timestamp;
  final double heartRate; // bpm (normal: 60-100)
  final double spO2; // % (normal: 95-100)
  final double respirationRate; // breaths/min (normal: 12-20)
  final double systolicBp; // mmHg (normal: 90-120)
  final double diastolicBp; // mmHg (normal: 60-80)
  final double temperature; // Celsius (normal: 36.5 - 37.5)
  final double signalQuality; // 0.0 - 1.0

  const TelemetryPoint({
    required this.timestamp,
    required this.heartRate,
    required this.spO2,
    required this.respirationRate,
    required this.systolicBp,
    required this.diastolicBp,
    required this.temperature,
    this.signalQuality = 0.98,
  });

  String get bloodPressureString => '${systolicBp.round()}/${diastolicBp.round()}';

  TelemetryPoint copyWith({
    DateTime? timestamp,
    double? heartRate,
    double? spO2,
    double? respirationRate,
    double? systolicBp,
    double? diastolicBp,
    double? temperature,
    double? signalQuality,
  }) {
    return TelemetryPoint(
      timestamp: timestamp ?? this.timestamp,
      heartRate: heartRate ?? this.heartRate,
      spO2: spO2 ?? this.spO2,
      respirationRate: respirationRate ?? this.respirationRate,
      systolicBp: systolicBp ?? this.systolicBp,
      diastolicBp: diastolicBp ?? this.diastolicBp,
      temperature: temperature ?? this.temperature,
      signalQuality: signalQuality ?? this.signalQuality,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'heartRate': heartRate,
      'spO2': spO2,
      'respirationRate': respirationRate,
      'systolicBp': systolicBp,
      'diastolicBp': diastolicBp,
      'temperature': temperature,
      'signalQuality': signalQuality,
    };
  }

  factory TelemetryPoint.fromJson(Map<String, dynamic> json) {
    return TelemetryPoint(
      timestamp: DateTime.parse(json['timestamp'] as String),
      heartRate: (json['heartRate'] as num).toDouble(),
      spO2: (json['spO2'] as num).toDouble(),
      respirationRate: (json['respirationRate'] as num).toDouble(),
      systolicBp: (json['systolicBp'] as num).toDouble(),
      diastolicBp: (json['diastolicBp'] as num).toDouble(),
      temperature: (json['temperature'] as num).toDouble(),
      signalQuality: (json['signalQuality'] as num?)?.toDouble() ?? 0.98,
    );
  }
}
