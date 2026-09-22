import 'package:flutter_test/flutter_test.dart';
import 'package:aegisyn_ai/services/ai/agents/audit_agent.dart';

void main() {
  group('Cryptographic AuditAgent Hash Chain Tests', () {
    late AuditAgent auditAgent;

    setUp(() {
      auditAgent = AuditAgent();
    });

    test('Genesis block is created with valid cryptographic structure', () {
      expect(auditAgent.records.isNotEmpty, isTrue);
      expect(auditAgent.records.first.sequenceIndex, 1);
      expect(auditAgent.records.first.previousHash, AuditAgent.genesisHash);
      expect(auditAgent.verifyChainIntegrity(), isTrue);
    });

    test('Chaining multiple clinical lifecycle events maintains cryptographic integrity', () {
      // 1. EVENT_DETECTED
      auditAgent.recordEvent(
        eventType: 'EVENT_DETECTED',
        actor: 'SignalAgent',
        actionSummary: 'Multi-parameter deviation detected for Patient 1048.',
        rawPayload: '{"hr": 128, "spo2": 89}',
      );

      // 2. AI_ANALYSIS_COMPLETED
      auditAgent.recordEvent(
        eventType: 'AI_ANALYSIS_COMPLETED',
        actor: 'AnomalyAgent',
        actionSummary: 'High priority multi-signal anomaly classified.',
        rawPayload: '{"priority": "HIGH", "confidence": 0.94}',
      );

      // 3. EVENT_ROUTED
      auditAgent.recordEvent(
        eventType: 'EVENT_ROUTED',
        actor: 'RoutingAgent',
        actionSummary: 'Routed to Duty Doctor and Nursing Station.',
        rawPayload: '{"recipients": ["Duty Doctor", "Nursing Station"]}',
      );

      // 4. AUDIT_RECORD_CREATED
      auditAgent.recordEvent(
        eventType: 'AUDIT_RECORD_CREATED',
        actor: 'AuditAgent',
        actionSummary: 'Record sealed in local vault.',
        rawPayload: '{"sealed": true}',
      );

      expect(auditAgent.records.length, 5); // 1 genesis + 4 lifecycle
      expect(auditAgent.verifyChainIntegrity(), isTrue);
    });
  });
}
