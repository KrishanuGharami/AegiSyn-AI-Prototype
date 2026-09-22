class ClinicalLog {
  final String id;
  final String patientId;
  final DateTime timestamp;
  final String category;
  final String actor;
  final String content;
  final Map<String, dynamic> metadata;

  const ClinicalLog({
    required this.id,
    required this.patientId,
    required this.timestamp,
    required this.category,
    required this.actor,
    required this.content,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'timestamp': timestamp.toIso8601String(),
      'category': category,
      'actor': actor,
      'content': content,
      'metadata': metadata,
    };
  }

  factory ClinicalLog.fromJson(Map<String, dynamic> json) {
    return ClinicalLog(
      id: json['id'] as String,
      patientId: json['patientId'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      category: json['category'] as String,
      actor: json['actor'] as String,
      content: json['content'] as String,
      metadata: Map<String, dynamic>.from(json['metadata'] as Map? ?? {}),
    );
  }
}
