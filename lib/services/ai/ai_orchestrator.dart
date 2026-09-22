import 'interfaces.dart';
import 'agents/signal_agent.dart';
import 'agents/clinical_log_agent.dart';
import 'agents/anomaly_agent.dart';
import 'agents/routing_agent.dart';
import 'agents/audit_agent.dart';

class AegiSynAIEngine implements AIEngine {
  final SignalAgent signalAgent;
  final ClinicalLogAgent clinicalLogAgent;
  final AnomalyAgent anomalyAgent;
  final RoutingAgent routingAgent;
  final AuditAgent auditAgent;

  AegiSynAIEngine({
    SignalAgent? signalAgent,
    ClinicalLogAgent? clinicalLogAgent,
    AnomalyAgent? anomalyAgent,
    RoutingAgent? routingAgent,
    AuditAgent? auditAgent,
  })  : signalAgent = signalAgent ?? SignalAgent(),
        clinicalLogAgent = clinicalLogAgent ?? ClinicalLogAgent(),
        anomalyAgent = anomalyAgent ?? AnomalyAgent(),
        routingAgent = routingAgent ?? RoutingAgent(),
        auditAgent = auditAgent ?? AuditAgent();

  @override
  String get engineName => 'AegiSyn Neural Perception Core';

  @override
  String get version => '2026.1-Edge';

  @override
  bool get isLocalOnDevice => true;

  @override
  Future<void> initialize() async {
    // Simulates instant on-device NPU model & weights binding
    await Future.delayed(const Duration(milliseconds: 150));
  }
}
