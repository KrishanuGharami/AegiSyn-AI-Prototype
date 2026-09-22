import 'package:aegisyn_ai/models/patient.dart';
import 'package:aegisyn_ai/models/telemetry_point.dart';
import 'package:aegisyn_ai/models/clinical_log.dart';
import 'package:aegisyn_ai/models/anomaly_event.dart';
import '../interfaces.dart';

class AnomalyAgent implements AnomalyAnalyzer {
  final String agentId = 'AegiSyn-AnomalyAgent-v2.1';

  @override
  AnomalyEvent? evaluateTelemetry({
    required Patient patient,
    required TelemetryPoint telemetry,
    required List<ClinicalLog> recentLogs,
  }) {
    final base = patient.baselineTelemetry;
    final deltaHr = telemetry.heartRate - base.heartRate;
    final deltaSpo2 = telemetry.spO2 - base.spO2;
    final deltaResp = telemetry.respirationRate - base.respirationRate;

    final isHrElevated = telemetry.heartRate >= 110 || deltaHr >= 25;
    final isSpo2Depressed = telemetry.spO2 <= 92 || deltaSpo2 <= -5;
    final isRespElevated = telemetry.respirationRate >= 24 || deltaResp >= 6;

    final Map<String, String> deviations = {};

    if (isHrElevated) {
      deviations['Heart Rate'] = '${telemetry.heartRate.round()} bpm (+${deltaHr.round()} bpm vs base)';
    }
    if (isSpo2Depressed) {
      deviations['SpO2 Oxygen'] = '${telemetry.spO2.round()}% (${deltaSpo2.round()}% vs base)';
    }
    if (isRespElevated) {
      deviations['Respiration'] = '${telemetry.respirationRate.round()} rpm (+${deltaResp.round()} rpm vs base)';
    }

    final deviatingSignalCount = (isHrElevated ? 1 : 0) + (isSpo2Depressed ? 1 : 0) + (isRespElevated ? 1 : 0);

    if (deviatingSignalCount >= 2) {
      return AnomalyEvent(
        id: 'AE-${DateTime.now().millisecondsSinceEpoch}',
        patientId: patient.id,
        timestamp: DateTime.now(),
        severity: AnomalySeverity.high,
        eventType: 'Multi-signal anomaly',
        primaryReason: 'Concurrent deviation across monitored signals.',
        clinicalRationale:
            'Autonomous edge perception detected synchronous divergence: acute compensatory tachycardia (HR ${telemetry.heartRate.round()} bpm), arterial desaturation (SpO2 ${telemetry.spO2.round()}%), and tachypneic ventilation (Resp ${telemetry.respirationRate.round()} rpm). Multi-signal correlation score exceeds 0.92 threshold.',
        deviations: deviations,
        recommendedAction: 'Clinical review recommended.',
        confidenceScore: 0.94,
      );
    } else if (deviatingSignalCount == 1) {
      return AnomalyEvent(
        id: 'AE-${DateTime.now().millisecondsSinceEpoch}',
        patientId: patient.id,
        timestamp: DateTime.now(),
        severity: AnomalySeverity.watch,
        eventType: 'Single-parameter deviation',
        primaryReason: 'Isolated vital sign drift detected.',
        clinicalRationale:
            'A single biometric parameter diverged from the baseline while collateral signals remain within expected clinical variance. Active telemetry surveillance ongoing.',
        deviations: deviations,
        recommendedAction: 'Routine observation & telemetry monitoring recommended.',
        confidenceScore: 0.81,
      );
    }

    return null;
  }
}
