import 'package:flutter_test/flutter_test.dart';
import 'package:aegisyn_ai/services/app_state.dart';
import 'package:aegisyn_ai/models/anomaly_event.dart';
import 'package:aegisyn_ai/services/office_kit/office_kit_bridge.dart';

void main() {
  group('AegiSyn AI Deterministic Hackathon Demo Workflow', () {
    late AppState appState;

    setUp(() {
      appState = AppState();
    });

    tearDown(() {
      appState.dispose();
    });

    test('Full End-to-End Clinical Flow: Normal -> Anomaly -> Review -> Route -> OfficeKit -> Audit', () async {
      // 1. NORMAL BASELINE STATE
      final initialPatient = appState.selectedPatient;
      expect(initialPatient.id, 'PAT-1048');
      expect(initialPatient.activeAnomaly, isNull);
      expect(initialPatient.baselineTelemetry.heartRate, 74.0);
      expect(initialPatient.baselineTelemetry.spO2, 98.0);

      // 2. TRIGGER MULTI-SIGNAL ANOMALY
      await appState.triggerMultiSignalAnomalyDemo();

      final anomalyPatient = appState.selectedPatient;
      expect(anomalyPatient.activeAnomaly, isNotNull);
      final anomaly = anomalyPatient.activeAnomaly!;
      expect(anomaly.severity, AnomalySeverity.high);
      expect(anomaly.eventType, 'Multi-signal anomaly');
      expect(anomaly.primaryReason, 'Concurrent deviation across monitored signals.');
      expect(anomaly.recommendedAction, 'Clinical review recommended.');

      // 3. CLINICIAN REVIEWS ANOMALY
      appState.markAnomalyReviewed(anomalyPatient.id);
      expect(appState.selectedPatient.activeAnomaly!.isReviewed, isTrue);

      // 4. ROUTE ALERT TO DUTY DOCTOR & NURSING STATION (+ VOICE MEMO)
      final recipients = [
        'Duty Doctor (Dr. Ananya Reddy - Cardiology)',
        'Nursing Station (ICU Pod 04)',
      ];

      await appState.routeActiveAnomaly(
        patientId: anomalyPatient.id,
        recipients: recipients,
        hasVoiceNote: true,
        voiceNoteDurationSeconds: 5,
        voiceNoteTranscript: 'Dr. Reddy: Acute multi-signal divergence observed for Bed 1048.',
      );

      // 5. OFFICE KIT WORKSTATION ACKNOWLEDGEMENT
      expect(appState.officeKitBridge.connectionState, OfficeKitConnectionState.syncAcknowledged);
      expect(appState.officeKitBridge.syncHistory.first.title, 'Clinical Handover Dispatched');

      // 6. CRYPTOGRAPHIC MERKLE AUDIT CHAIN VERIFICATION
      final records = appState.auditRecords;
      expect(records.any((r) => r.eventType == 'EVENT_DETECTED'), isTrue);
      expect(records.any((r) => r.eventType == 'AI_ANALYSIS_COMPLETED'), isTrue);
      expect(records.any((r) => r.eventType == 'EVENT_ROUTED'), isTrue);
      expect(records.any((r) => r.eventType == 'AUDIT_RECORD_CREATED'), isTrue);
      expect(appState.aiEngine.auditAgent.verifyChainIntegrity(), isTrue);

      // 7. RESTORE BASELINE
      appState.resetPatientToBaseline();
      expect(appState.selectedPatient.activeAnomaly, isNull);
    });
  });
}
