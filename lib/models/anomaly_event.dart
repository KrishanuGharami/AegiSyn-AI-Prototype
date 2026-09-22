enum AnomalySeverity {
  normal,
  watch,
  high,
  critical,
}

extension AnomalySeverityExtension on AnomalySeverity {
  String get label {
    switch (this) {
      case AnomalySeverity.normal:
        return 'NORMAL';
      case AnomalySeverity.watch:
        return 'WATCH';
      case AnomalySeverity.high:
        return 'HIGH';
      case AnomalySeverity.critical:
        return 'CRITICAL';
    }
  }
}

class AnomalyEvent {
  final String id;
  final String patientId;
  final DateTime timestamp;
  final AnomalySeverity severity;
  final String eventType;
  final String primaryReason;
  final String clinicalRationale;
  final Map<String, String> deviations;
  final String recommendedAction;
  final double confidenceScore;
  final bool isReviewed;
  final bool isRouted;
  final List<String> routedDestinations;
  final DateTime? routedAt;

  const AnomalyEvent({
    required this.id,
    required this.patientId,
    required this.timestamp,
    required this.severity,
    required this.eventType,
    required this.primaryReason,
    required this.clinicalRationale,
    required this.deviations,
    required this.recommendedAction,
    this.confidenceScore = 0.94,
    this.isReviewed = false,
    this.isRouted = false,
    this.routedDestinations = const [],
    this.routedAt,
  });

  AnomalyEvent copyWith({
    String? id,
    String? patientId,
    DateTime? timestamp,
    AnomalySeverity? severity,
    String? eventType,
    String? primaryReason,
    String? clinicalRationale,
    Map<String, String>? deviations,
    String? recommendedAction,
    double? confidenceScore,
    bool? isReviewed,
    bool? isRouted,
    List<String>? routedDestinations,
    DateTime? routedAt,
  }) {
    return AnomalyEvent(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      timestamp: timestamp ?? this.timestamp,
      severity: severity ?? this.severity,
      eventType: eventType ?? this.eventType,
      primaryReason: primaryReason ?? this.primaryReason,
      clinicalRationale: clinicalRationale ?? this.clinicalRationale,
      deviations: deviations ?? this.deviations,
      recommendedAction: recommendedAction ?? this.recommendedAction,
      confidenceScore: confidenceScore ?? this.confidenceScore,
      isReviewed: isReviewed ?? this.isReviewed,
      isRouted: isRouted ?? this.isRouted,
      routedDestinations: routedDestinations ?? this.routedDestinations,
      routedAt: routedAt ?? this.routedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'timestamp': timestamp.toIso8601String(),
      'severity': severity.name,
      'eventType': eventType,
      'primaryReason': primaryReason,
      'clinicalRationale': clinicalRationale,
      'deviations': deviations,
      'recommendedAction': recommendedAction,
      'confidenceScore': confidenceScore,
      'isReviewed': isReviewed,
      'isRouted': isRouted,
      'routedDestinations': routedDestinations,
      'routedAt': routedAt?.toIso8601String(),
    };
  }

  factory AnomalyEvent.fromJson(Map<String, dynamic> json) {
    return AnomalyEvent(
      id: json['id'] as String,
      patientId: json['patientId'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      severity: AnomalySeverity.values.byName(json['severity'] as String),
      eventType: json['eventType'] as String,
      primaryReason: json['primaryReason'] as String,
      clinicalRationale: json['clinicalRationale'] as String,
      deviations: Map<String, String>.from(json['deviations'] as Map),
      recommendedAction: json['recommendedAction'] as String,
      confidenceScore: (json['confidenceScore'] as num?)?.toDouble() ?? 0.94,
      isReviewed: json['isReviewed'] as bool? ?? false,
      isRouted: json['isRouted'] as bool? ?? false,
      routedDestinations: List<String>.from(json['routedDestinations'] as List? ?? []),
      routedAt: json['routedAt'] != null ? DateTime.parse(json['routedAt'] as String) : null,
    );
  }
}
