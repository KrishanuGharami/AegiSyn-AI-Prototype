import '../../models/patient.dart';
import '../../models/telemetry_point.dart';
import '../../models/clinical_log.dart';
import '../../models/anomaly_event.dart';
import '../../models/routing_decision.dart';
import '../../models/audit_record.dart';

/// Top-level AI Engine contract for on-device inference and orchestration
abstract class AIEngine {
  String get engineName;
  String get version;
  bool get isLocalOnDevice;
  Future<void> initialize();
}

/// Interface for analyzing raw biometric signal streams
abstract class SignalAnalyzer {
  TelemetryPoint filterAndSmooth(TelemetryPoint raw, List<TelemetryPoint> recentWindow);
  bool isSignalQualityAcceptable(TelemetryPoint point);
  Map<String, double> computeSignalDeltas(TelemetryPoint current, TelemetryPoint baseline);
}

/// Interface for parsing and correlating clinical context and notes
abstract class ClinicalLogAnalyzer {
  List<ClinicalLog> extractContextualNotes(String patientId);
  String summarizeRecentTimeline(List<ClinicalLog> logs);
}

/// Interface for classifying single and multi-signal anomalies
abstract class AnomalyAnalyzer {
  AnomalyEvent? evaluateTelemetry({
    required Patient patient,
    required TelemetryPoint telemetry,
    required List<ClinicalLog> recentLogs,
  });
}

/// Interface for clinical workflow prioritization and destination routing
abstract class RoutingEngine {
  RoutingDecision determineRouting({
    required AnomalyEvent anomaly,
    required Patient patient,
    required List<String> selectedRecipients,
    bool hasVoiceNote = false,
    int voiceNoteDurationSeconds = 0,
    String? voiceNoteTranscript,
  });
  List<String> getSuggestedRecipients(AnomalySeverity severity);
}

/// Interface for cryptographic tamper-evident audit service
abstract class AuditService {
  List<AuditRecord> get records;
  AuditRecord recordEvent({
    required String eventType,
    required String actor,
    required String actionSummary,
    required String rawPayload,
  });
  bool verifyChainIntegrity();
}
