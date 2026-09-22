import 'anomaly_event.dart';

class RoutingDecision {
  final String id;
  final String anomalyEventId;
  final String patientId;
  final DateTime timestamp;
  final AnomalySeverity priority;
  final List<String> recipients;
  final String clinicalSummary;
  final String dispatchedBy;
  final String officeKitHandoverStatus; // "LOCAL_QUEUED", "TRANSMITTED", "ACKNOWLEDGED"
  final DateTime? acknowledgedAt;
  final bool hasVoiceNote;
  final int voiceNoteDurationSeconds;
  final String? voiceNoteTranscript;

  const RoutingDecision({
    required this.id,
    required this.anomalyEventId,
    required this.patientId,
    required this.timestamp,
    required this.priority,
    required this.recipients,
    required this.clinicalSummary,
    this.dispatchedBy = 'RoutingAgent (On-Device)',
    this.officeKitHandoverStatus = 'TRANSMITTED',
    this.acknowledgedAt,
    this.hasVoiceNote = false,
    this.voiceNoteDurationSeconds = 0,
    this.voiceNoteTranscript,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'anomalyEventId': anomalyEventId,
      'patientId': patientId,
      'timestamp': timestamp.toIso8601String(),
      'priority': priority.name,
      'recipients': recipients,
      'clinicalSummary': clinicalSummary,
      'dispatchedBy': dispatchedBy,
      'officeKitHandoverStatus': officeKitHandoverStatus,
      'acknowledgedAt': acknowledgedAt?.toIso8601String(),
      'hasVoiceNote': hasVoiceNote,
      'voiceNoteDurationSeconds': voiceNoteDurationSeconds,
      'voiceNoteTranscript': voiceNoteTranscript,
    };
  }

  factory RoutingDecision.fromJson(Map<String, dynamic> json) {
    return RoutingDecision(
      id: json['id'] as String,
      anomalyEventId: json['anomalyEventId'] as String,
      patientId: json['patientId'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      priority: AnomalySeverity.values.byName(json['priority'] as String),
      recipients: List<String>.from(json['recipients'] as List),
      clinicalSummary: json['clinicalSummary'] as String,
      dispatchedBy: json['dispatchedBy'] as String? ?? 'RoutingAgent (On-Device)',
      officeKitHandoverStatus: json['officeKitHandoverStatus'] as String? ?? 'TRANSMITTED',
      acknowledgedAt: json['acknowledgedAt'] != null ? DateTime.parse(json['acknowledgedAt'] as String) : null,
      hasVoiceNote: json['hasVoiceNote'] as bool? ?? false,
      voiceNoteDurationSeconds: json['voiceNoteDurationSeconds'] as int? ?? 0,
      voiceNoteTranscript: json['voiceNoteTranscript'] as String?,
    );
  }
}
