import 'dart:math';
import '../../models/patient.dart';
import '../../models/telemetry_point.dart';

class TelemetryStreamService {
  final Random _rng = Random();

  List<Patient> getInitialSyntheticPatients() {
    final now = DateTime.now();

    final p1048Base = TelemetryPoint(
      timestamp: now,
      heartRate: 74,
      spO2: 98,
      respirationRate: 16,
      systolicBp: 120,
      diastolicBp: 80,
      temperature: 37.0,
      signalQuality: 0.99,
    );

    final p1052Base = TelemetryPoint(
      timestamp: now,
      heartRate: 68,
      spO2: 99,
      respirationRate: 14,
      systolicBp: 118,
      diastolicBp: 76,
      temperature: 36.8,
      signalQuality: 0.98,
    );

    final p1061Base = TelemetryPoint(
      timestamp: now,
      heartRate: 92,
      spO2: 95,
      respirationRate: 19,
      systolicBp: 134,
      diastolicBp: 86,
      temperature: 37.2,
      signalQuality: 0.96,
    );

    final p1075Base = TelemetryPoint(
      timestamp: now,
      heartRate: 72,
      spO2: 98,
      respirationRate: 15,
      systolicBp: 112,
      diastolicBp: 74,
      temperature: 36.9,
      signalQuality: 0.99,
    );

    return [
      Patient(
        id: 'PAT-1048',
        displayId: '1048',
        ward: 'ICU Pod 04 - Hyderabad General',
        age: 58,
        gender: 'Male',
        admissionReason: 'Post-Operative Thoracic Telemetry',
        currentTelemetry: p1048Base,
        baselineTelemetry: p1048Base,
        telemetryHistory: _generateInitialWave(p1048Base, 20),
        isDemoSubject: true,
      ),
      Patient(
        id: 'PAT-1052',
        displayId: '1052',
        ward: 'Step-Down Unit Bed 12',
        age: 44,
        gender: 'Female',
        admissionReason: 'Cardiology Observation',
        currentTelemetry: p1052Base,
        baselineTelemetry: p1052Base,
        telemetryHistory: _generateInitialWave(p1052Base, 20),
      ),
      Patient(
        id: 'PAT-1061',
        displayId: '1061',
        ward: 'Coronary Care Bed 03',
        age: 71,
        gender: 'Male',
        admissionReason: 'Arrhythmia Surveillance',
        currentTelemetry: p1061Base,
        baselineTelemetry: p1061Base,
        telemetryHistory: _generateInitialWave(p1061Base, 20),
      ),
      Patient(
        id: 'PAT-1075',
        displayId: '1075',
        ward: 'Post-Op Ward 08',
        age: 33,
        gender: 'Female',
        admissionReason: 'Orthopedic Recovery',
        currentTelemetry: p1075Base,
        baselineTelemetry: p1075Base,
        telemetryHistory: _generateInitialWave(p1075Base, 20),
      ),
    ];
  }

  List<TelemetryPoint> _generateInitialWave(TelemetryPoint base, int count) {
    final list = <TelemetryPoint>[];
    final now = DateTime.now();
    for (int i = count; i >= 0; i--) {
      final jitterHr = (_rng.nextDouble() * 2 - 1);
      final jitterSpo2 = (_rng.nextDouble() * 0.8 - 0.4);
      final point = base.copyWith(
        timestamp: now.subtract(Duration(seconds: i * 2)),
        heartRate: base.heartRate + jitterHr,
        spO2: (base.spO2 + jitterSpo2).clamp(80.0, 100.0),
      );
      list.add(point);
    }
    return list;
  }

  TelemetryPoint computeNextTelemetry(TelemetryPoint current, {bool isAnomalyState = false}) {
    if (isAnomalyState) {
      // Deterministic Anomaly values with subtle jitter: HR ~128, SpO2 ~89, Resp ~28
      final hrJitter = (_rng.nextDouble() * 4 - 2);
      final spo2Jitter = (_rng.nextDouble() * 1.5 - 0.7);
      final respJitter = (_rng.nextDouble() * 2 - 1);

      return current.copyWith(
        timestamp: DateTime.now(),
        heartRate: double.parse((128.0 + hrJitter).toStringAsFixed(1)),
        spO2: double.parse((89.0 + spo2Jitter).clamp(85.0, 93.0).toStringAsFixed(1)),
        respirationRate: double.parse((28.0 + respJitter).toStringAsFixed(1)),
        systolicBp: 142 + (_rng.nextInt(5) - 2).toDouble(),
        diastolicBp: 92 + (_rng.nextInt(4) - 2).toDouble(),
        temperature: 37.8,
        signalQuality: 0.97,
      );
    } else {
      // Normal subtle physiological breathing/sinus fluctuation
      final hrJitter = (_rng.nextDouble() * 2.4 - 1.2);
      final spo2Jitter = (_rng.nextDouble() * 0.6 - 0.3);
      final respJitter = (_rng.nextDouble() * 1.2 - 0.6);

      return current.copyWith(
        timestamp: DateTime.now(),
        heartRate: double.parse((current.heartRate + hrJitter * 0.3).clamp(65.0, 84.0).toStringAsFixed(1)),
        spO2: double.parse((current.spO2 + spo2Jitter * 0.2).clamp(96.0, 100.0).toStringAsFixed(1)),
        respirationRate: double.parse((current.respirationRate + respJitter * 0.3).clamp(13.0, 18.0).toStringAsFixed(1)),
        signalQuality: 0.99,
      );
    }
  }
}
