import 'package:aegisyn_ai/models/audit_record.dart';
import '../interfaces.dart';

class AuditAgent implements AuditService {
  final String agentId = 'AegiSyn-AuditAgent-v1.8';
  final List<AuditRecord> _records = [];
  static const String genesisHash = '0000000000000000000000000000000000000000000000000000000000000000';

  AuditAgent() {
    _initGenesis();
  }

  void _initGenesis() {
    if (_records.isEmpty) {
      final genesis = AuditRecord.create(
        sequenceIndex: 1,
        timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
        eventType: 'VAULT_INITIALIZED',
        actor: 'SecuritySubsystem (iQOO Secure Element)',
        actionSummary: 'Local cryptographic audit vault initialized on-device. Zero cloud leakage active.',
        rawPayload: '{"status": "INITIALIZED", "hardwareKey": "ARM_TEE_HARDENED", "privacyMode": "MAX_MINIMIZATION"}',
        previousHash: genesisHash,
      );
      _records.add(genesis);
    }
  }

  @override
  List<AuditRecord> get records => List.unmodifiable(_records);

  @override
  AuditRecord recordEvent({
    required String eventType,
    required String actor,
    required String actionSummary,
    required String rawPayload,
  }) {
    final prevHash = _records.isNotEmpty ? _records.last.recordHash : genesisHash;
    final nextIndex = _records.length + 1;

    final record = AuditRecord.create(
      sequenceIndex: nextIndex,
      timestamp: DateTime.now(),
      eventType: eventType,
      actor: actor,
      actionSummary: actionSummary,
      rawPayload: rawPayload,
      previousHash: prevHash,
    );

    _records.add(record);
    return record;
  }

  @override
  bool verifyChainIntegrity() {
    if (_records.isEmpty) return true;
    String expectedPrevHash = genesisHash;

    for (final record in _records) {
      if (!record.verify(expectedPrevHash)) {
        return false;
      }
      expectedPrevHash = record.recordHash;
    }
    return true;
  }

  void resetToGenesis() {
    _records.clear();
    _initGenesis();
  }
}
