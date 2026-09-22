import 'package:flutter_test/flutter_test.dart';
import 'package:aegisyn_ai/models/anomaly_event.dart';
import 'package:aegisyn_ai/models/routing_decision.dart';
import 'package:aegisyn_ai/services/office_kit/office_kit_bridge.dart';

void main() {
  group('OfficeKitBridge Unit Tests', () {
    late OfficeKitBridge bridge;

    setUp(() {
      bridge = SimulatedOfficeKitBridge();
    });

    test('SimulatedOfficeKitBridge clearly identifies as development fallback', () {
      expect(bridge.isDevelopmentFallback, isTrue);
      expect(bridge.peerDeviceName.contains('Workstation'), isTrue);
      expect(bridge.connectionState, OfficeKitConnectionState.connected);
    });

    test('Transmitting clinical handover records sync history event and updates state', () async {
      final decision = RoutingDecision(
        id: 'RD-TEST-001',
        anomalyEventId: 'AE-TEST-001',
        patientId: 'PAT-1048',
        timestamp: DateTime.now(),
        priority: AnomalySeverity.high,
        recipients: ['Duty Doctor', 'Nursing Station'],
        clinicalSummary: 'Test clinical handover packet',
      );

      final initialCount = bridge.syncHistory.length;
      final success = await bridge.transmitClinicalHandover(decision);

      expect(success, isTrue);
      expect(bridge.connectionState, OfficeKitConnectionState.syncAcknowledged);
      expect(bridge.syncHistory.length, initialCount + 1);
      expect(bridge.syncHistory.first.title, 'Clinical Handover Dispatched');
    });
  });
}
