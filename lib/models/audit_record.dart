import 'dart:convert';
import 'package:crypto/crypto.dart';

class AuditRecord {
  final int sequenceIndex;
  final DateTime timestamp;
  final String eventType; // e.g., 'EVENT_DETECTED', 'AI_ANALYSIS_COMPLETED', 'EVENT_ROUTED', 'AUDIT_RECORD_CREATED'
  final String actor; // e.g., 'SignalAgent', 'AnomalyAgent', 'RoutingAgent', 'AuditAgent'
  final String actionSummary;
  final String payloadDigest; // SHA-256 hash of the payload
  final String previousHash; // SHA-256 hash of previous audit record
  final String recordHash; // Cryptographic hash sealing this block

  const AuditRecord({
    required this.sequenceIndex,
    required this.timestamp,
    required this.eventType,
    required this.actor,
    required this.actionSummary,
    required this.payloadDigest,
    required this.previousHash,
    required this.recordHash,
  });

  static String calculateHash({
    required int sequenceIndex,
    required DateTime timestamp,
    required String eventType,
    required String actor,
    required String payloadDigest,
    required String previousHash,
  }) {
    final raw = '$sequenceIndex:${timestamp.toIso8601String()}:$eventType:$actor:$payloadDigest:$previousHash';
    return sha256.convert(utf8.encode(raw)).toString();
  }

  static AuditRecord create({
    required int sequenceIndex,
    required DateTime timestamp,
    required String eventType,
    required String actor,
    required String actionSummary,
    required String rawPayload,
    required String previousHash,
  }) {
    final payloadDigest = sha256.convert(utf8.encode(rawPayload)).toString();
    final recordHash = calculateHash(
      sequenceIndex: sequenceIndex,
      timestamp: timestamp,
      eventType: eventType,
      actor: actor,
      payloadDigest: payloadDigest,
      previousHash: previousHash,
    );

    return AuditRecord(
      sequenceIndex: sequenceIndex,
      timestamp: timestamp,
      eventType: eventType,
      actor: actor,
      actionSummary: actionSummary,
      payloadDigest: payloadDigest,
      previousHash: previousHash,
      recordHash: recordHash,
    );
  }

  bool verify(String expectedPrevHash) {
    if (previousHash != expectedPrevHash) return false;
    final computed = calculateHash(
      sequenceIndex: sequenceIndex,
      timestamp: timestamp,
      eventType: eventType,
      actor: actor,
      payloadDigest: payloadDigest,
      previousHash: previousHash,
    );
    return computed == recordHash;
  }

  Map<String, dynamic> toJson() {
    return {
      'sequenceIndex': sequenceIndex,
      'timestamp': timestamp.toIso8601String(),
      'eventType': eventType,
      'actor': actor,
      'actionSummary': actionSummary,
      'payloadDigest': payloadDigest,
      'previousHash': previousHash,
      'recordHash': recordHash,
    };
  }
}
