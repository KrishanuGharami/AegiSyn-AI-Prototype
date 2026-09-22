import 'package:aegisyn_ai/models/patient.dart';
import 'package:aegisyn_ai/models/anomaly_event.dart';
import 'package:aegisyn_ai/models/routing_decision.dart';
import '../interfaces.dart';

class RoutingAgent implements RoutingEngine {
  final String agentId = 'AegiSyn-RoutingAgent-v2.0';

  @override
  List<String> getSuggestedRecipients(AnomalySeverity severity) {
    switch (severity) {
      case AnomalySeverity.critical:
      case AnomalySeverity.high:
        return [
          'Duty Doctor (Cardiology / Dr. Ananya Reddy)',
          'Nursing Station (ICU Pod 04)',
          'Rapid Response Team',
        ];
      case AnomalySeverity.watch:
        return [
          'Assigned Staff Nurse',
          'Ward Telemetry Monitor',
        ];
      case AnomalySeverity.normal:
        return [
          'Routine Electronic Health Log',
        ];
    }
  }

  @override
  RoutingDecision determineRouting({
    required AnomalyEvent anomaly,
    required Patient patient,
    required List<String> selectedRecipients,
    bool hasVoiceNote = false,
    int voiceNoteDurationSeconds = 0,
    String? voiceNoteTranscript,
  }) {
    final summary =
        'Priority: ${anomaly.severity.label} • Event: ${anomaly.eventType} for Patient ${patient.displayId} (${patient.ward}). '
        'Reason: ${anomaly.primaryReason} Action: ${anomaly.recommendedAction}'
        '${hasVoiceNote ? " • [Voice Memo Attached: $voiceNoteDurationSeconds s]" : ""}';

    return RoutingDecision(
      id: 'RD-${DateTime.now().millisecondsSinceEpoch}',
      anomalyEventId: anomaly.id,
      patientId: patient.id,
      timestamp: DateTime.now(),
      priority: anomaly.severity,
      recipients: selectedRecipients.isNotEmpty ? selectedRecipients : getSuggestedRecipients(anomaly.severity),
      clinicalSummary: summary,
      dispatchedBy: '$agentId (On-Device Intelligence)',
      officeKitHandoverStatus: 'TRANSMITTED',
      acknowledgedAt: DateTime.now(),
      hasVoiceNote: hasVoiceNote,
      voiceNoteDurationSeconds: voiceNoteDurationSeconds,
      voiceNoteTranscript: voiceNoteTranscript,
    );
  }
}
