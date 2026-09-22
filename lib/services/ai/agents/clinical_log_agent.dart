import 'package:aegisyn_ai/models/clinical_log.dart';
import '../interfaces.dart';

class ClinicalLogAgent implements ClinicalLogAnalyzer {
  final String agentId = 'AegiSyn-ClinicalLogAgent-v1.2';

  @override
  List<ClinicalLog> extractContextualNotes(String patientId) {
    final now = DateTime.now();
    return [
      ClinicalLog(
        id: 'LOG-001',
        patientId: patientId,
        timestamp: now.subtract(const Duration(minutes: 45)),
        category: 'CLINICAL_NOTE',
        actor: 'Dr. Ananya Reddy (Cardiology)',
        content: 'Patient admitted for 24hr post-thoracic telemetry monitoring. Prescribed low-dose beta-blocker.',
      ),
      ClinicalLog(
        id: 'LOG-002',
        patientId: patientId,
        timestamp: now.subtract(const Duration(minutes: 20)),
        category: 'MEDICATION_ADMIN',
        actor: 'Staff Nurse B. Naidu',
        content: 'Administered maintenance IV saline 50mL/hr. Baseline vitals stable.',
      ),
    ];
  }

  @override
  String summarizeRecentTimeline(List<ClinicalLog> logs) {
    if (logs.isEmpty) return 'No prior clinical logs recorded in current shift.';
    final recent = logs.take(2).map((l) => '[${l.actor}]: ${l.content}').join(' • ');
    return 'Recent shift context: $recent';
  }
}
