import 'telemetry_point.dart';
import 'anomaly_event.dart';

class Patient {
  final String id;
  final String displayId;
  final String ward;
  final int age;
  final String gender;
  final String admissionReason;
  final TelemetryPoint currentTelemetry;
  final List<TelemetryPoint> telemetryHistory;
  final TelemetryPoint baselineTelemetry;
  final AnomalyEvent? activeAnomaly;
  final bool isDemoSubject;

  const Patient({
    required this.id,
    required this.displayId,
    required this.ward,
    required this.age,
    required this.gender,
    required this.admissionReason,
    required this.currentTelemetry,
    required this.telemetryHistory,
    required this.baselineTelemetry,
    this.activeAnomaly,
    this.isDemoSubject = false,
  });

  Patient copyWith({
    String? id,
    String? displayId,
    String? ward,
    int? age,
    String? gender,
    String? admissionReason,
    TelemetryPoint? currentTelemetry,
    List<TelemetryPoint>? telemetryHistory,
    TelemetryPoint? baselineTelemetry,
    AnomalyEvent? activeAnomaly,
    bool clearActiveAnomaly = false,
    bool? isDemoSubject,
  }) {
    return Patient(
      id: id ?? this.id,
      displayId: displayId ?? this.displayId,
      ward: ward ?? this.ward,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      admissionReason: admissionReason ?? this.admissionReason,
      currentTelemetry: currentTelemetry ?? this.currentTelemetry,
      telemetryHistory: telemetryHistory ?? this.telemetryHistory,
      baselineTelemetry: baselineTelemetry ?? this.baselineTelemetry,
      activeAnomaly: clearActiveAnomaly ? null : (activeAnomaly ?? this.activeAnomaly),
      isDemoSubject: isDemoSubject ?? this.isDemoSubject,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'displayId': displayId,
      'ward': ward,
      'age': age,
      'gender': gender,
      'admissionReason': admissionReason,
      'currentTelemetry': currentTelemetry.toJson(),
      'telemetryHistory': telemetryHistory.map((e) => e.toJson()).toList(),
      'baselineTelemetry': baselineTelemetry.toJson(),
      'activeAnomaly': activeAnomaly?.toJson(),
      'isDemoSubject': isDemoSubject,
    };
  }
}
