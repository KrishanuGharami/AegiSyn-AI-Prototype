import 'package:flutter_test/flutter_test.dart';
import 'package:aegisyn_ai/models/patient.dart';
import 'package:aegisyn_ai/models/telemetry_point.dart';
import 'package:aegisyn_ai/models/anomaly_event.dart';
import 'package:aegisyn_ai/services/ai/agents/anomaly_agent.dart';

void main() {
  group('AnomalyAgent Unit Tests', () {
    late AnomalyAgent agent;
    late Patient baselinePatient;

    setUp(() {
      agent = AnomalyAgent();
      final base = TelemetryPoint(
        timestamp: DateTime.now(),
        heartRate: 74,
        spO2: 98,
        respirationRate: 16,
        systolicBp: 120,
        diastolicBp: 80,
        temperature: 37.0,
      );

      baselinePatient = Patient(
        id: 'PAT-1048',
        displayId: '1048',
        ward: 'ICU Pod 04',
        age: 58,
        gender: 'Male',
        admissionReason: 'Thoracic Telemetry',
        currentTelemetry: base,
        baselineTelemetry: base,
        telemetryHistory: [base],
      );
    });

    test('Baseline normal telemetry returns null anomaly', () {
      final normalPoint = baselinePatient.baselineTelemetry;
      final result = agent.evaluateTelemetry(
        patient: baselinePatient,
        telemetry: normalPoint,
        recentLogs: [],
      );

      expect(result, isNull);
    });

    test('Patient 1048 acute multi-signal deviation triggers HIGH priority multi-signal anomaly', () {
      final anomalyPoint = TelemetryPoint(
        timestamp: DateTime.now(),
        heartRate: 128,
        spO2: 89,
        respirationRate: 28,
        systolicBp: 142,
        diastolicBp: 92,
        temperature: 37.8,
      );

      final result = agent.evaluateTelemetry(
        patient: baselinePatient,
        telemetry: anomalyPoint,
        recentLogs: [],
      );

      expect(result, isNotNull);
      expect(result!.severity, AnomalySeverity.high);
      expect(result.eventType, 'Multi-signal anomaly');
      expect(result.primaryReason, 'Concurrent deviation across monitored signals.');
      expect(result.recommendedAction, 'Clinical review recommended.');
      expect(result.deviations.containsKey('Heart Rate'), isTrue);
      expect(result.deviations.containsKey('SpO2 Oxygen'), isTrue);
      expect(result.deviations.containsKey('Respiration'), isTrue);
    });
  });
}
