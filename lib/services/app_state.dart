import 'dart:async';
import 'package:flutter/material.dart';
import '../models/patient.dart';
import '../models/telemetry_point.dart';
import '../models/routing_decision.dart';
import '../models/audit_record.dart';
import 'ai/ai_orchestrator.dart';
import 'device/telemetry_stream_service.dart';
import 'device/haptics_service.dart';
import 'storage/secure_vault_service.dart';
import 'office_kit/office_kit_bridge.dart';

class AppState extends ChangeNotifier {
  final AegiSynAIEngine aiEngine;
  final TelemetryStreamService telemetryService;
  final SecureVaultService vaultService;
  final OfficeKitBridge officeKitBridge;

  List<Patient> _patients = [];
  String _selectedPatientId = 'PAT-1048';
  bool _isLiveStreaming = true;
  bool _isDemoAnomalyActive = false;
  Timer? _telemetryTimer;

  final List<RoutingDecision> _routingHistory = [];

  AppState({
    AegiSynAIEngine? aiEngine,
    TelemetryStreamService? telemetryService,
    SecureVaultService? vaultService,
    OfficeKitBridge? officeKitBridge,
  })  : aiEngine = aiEngine ?? AegiSynAIEngine(),
        telemetryService = telemetryService ?? TelemetryStreamService(),
        vaultService = vaultService ?? SecureVaultService(),
        officeKitBridge = officeKitBridge ?? SimulatedOfficeKitBridge() {
    _init();
  }

  void _init() {
    _patients = telemetryService.getInitialSyntheticPatients();
    _startTelemetryStream();
  }

  List<Patient> get patients => _patients;
  String get selectedPatientId => _selectedPatientId;
  bool get isLiveStreaming => _isLiveStreaming;
  bool get isDemoAnomalyActive => _isDemoAnomalyActive;
  List<RoutingDecision> get routingHistory => List.unmodifiable(_routingHistory);
  List<AuditRecord> get auditRecords => aiEngine.auditAgent.records;

  Patient get selectedPatient {
    return _patients.firstWhere(
      (p) => p.id == _selectedPatientId,
      orElse: () => _patients.first,
    );
  }

  Patient? get demoPatient {
    try {
      return _patients.firstWhere((p) => p.isDemoSubject);
    } catch (_) {
      return null;
    }
  }

  void selectPatient(String id) {
    _selectedPatientId = id;
    HapticsService.triggerSelection();
    notifyListeners();
  }

  void toggleLiveStreaming() {
    _isLiveStreaming = !_isLiveStreaming;
    if (_isLiveStreaming) {
      _startTelemetryStream();
    } else {
      _telemetryTimer?.cancel();
    }
    notifyListeners();
  }

  void _startTelemetryStream() {
    _telemetryTimer?.cancel();
    _telemetryTimer = Timer.periodic(const Duration(milliseconds: 1400), (_) {
      _tickTelemetry();
    });
  }

  void _tickTelemetry() {
    bool hasChanged = false;
    final updated = <Patient>[];

    for (final p in _patients) {
      final isDemoSubject = p.isDemoSubject;
      final nextTelemetry = telemetryService.computeNextTelemetry(
        p.currentTelemetry,
        isAnomalyState: isDemoSubject && _isDemoAnomalyActive,
      );

      // Keep recent 25 telemetry points for real-time waveform sparkline rendering
      final history = [...p.telemetryHistory.skip(p.telemetryHistory.length > 25 ? 1 : 0), nextTelemetry];

      updated.add(p.copyWith(
        currentTelemetry: nextTelemetry,
        telemetryHistory: history,
      ));
      hasChanged = true;
    }

    if (hasChanged) {
      _patients = updated;
      notifyListeners();
    }
  }

  /// PRIMARY DETERMINISTIC DEMO TRIGGER:
  /// Patient 1048 multi-signal anomaly flow
  Future<void> triggerMultiSignalAnomalyDemo() async {
    _isDemoAnomalyActive = true;

    // 1. Instantly inject acute multi-signal deviation for Patient 1048
    final index = _patients.indexWhere((p) => p.id == 'PAT-1048');
    if (index == -1) return;

    final targetPatient = _patients[index];
    final anomalyTelemetry = TelemetryPoint(
      timestamp: DateTime.now(),
      heartRate: 128.0,
      spO2: 89.0,
      respirationRate: 28.0,
      systolicBp: 142.0,
      diastolicBp: 92.0,
      temperature: 37.8,
      signalQuality: 0.98,
    );

    // 2. Multi-Agent AI evaluation
    final logs = aiEngine.clinicalLogAgent.extractContextualNotes(targetPatient.id);
    final anomalyEvent = aiEngine.anomalyAgent.evaluateTelemetry(
      patient: targetPatient,
      telemetry: anomalyTelemetry,
      recentLogs: logs,
    );

    // 3. Tactile Emergency Alarm
    await HapticsService.triggerCriticalAnomalyAlarm();

    // 4. Audit Agent records cryptographic events
    if (anomalyEvent != null) {
      aiEngine.auditAgent.recordEvent(
        eventType: 'EVENT_DETECTED',
        actor: aiEngine.signalAgent.agentId,
        actionSummary: 'Multi-parameter acute deviation detected for Patient ${targetPatient.displayId}.',
        rawPayload: anomalyTelemetry.toJson().toString(),
      );

      aiEngine.auditAgent.recordEvent(
        eventType: 'AI_ANALYSIS_COMPLETED',
        actor: aiEngine.anomalyAgent.agentId,
        actionSummary: 'Multi-signal anomaly classified: High Priority. Action: Clinical review recommended.',
        rawPayload: anomalyEvent.toJson().toString(),
      );
    }

    // 5. Update patient state
    final history = [...targetPatient.telemetryHistory, anomalyTelemetry];
    _patients[index] = targetPatient.copyWith(
      currentTelemetry: anomalyTelemetry,
      telemetryHistory: history,
      activeAnomaly: anomalyEvent,
    );

    _selectedPatientId = 'PAT-1048';
    notifyListeners();
  }

  /// Reset Patient 1048 to normal baseline
  void resetPatientToBaseline() {
    _isDemoAnomalyActive = false;
    final index = _patients.indexWhere((p) => p.id == 'PAT-1048');
    if (index == -1) return;

    final target = _patients[index];
    final base = target.baselineTelemetry.copyWith(timestamp: DateTime.now());

    aiEngine.auditAgent.recordEvent(
      eventType: 'TELEMETRY_BASELINE_RESTORED',
      actor: 'ClinicalSupervisor',
      actionSummary: 'Patient ${target.displayId} telemetry restored to normal baseline.',
      rawPayload: base.toJson().toString(),
    );

    _patients[index] = target.copyWith(
      currentTelemetry: base,
      clearActiveAnomaly: true,
    );

    notifyListeners();
  }

  /// Mark active anomaly as reviewed
  void markAnomalyReviewed(String patientId) {
    final index = _patients.indexWhere((p) => p.id == patientId);
    if (index == -1) return;

    final p = _patients[index];
    if (p.activeAnomaly != null) {
      final updatedAnomaly = p.activeAnomaly!.copyWith(isReviewed: true);
      _patients[index] = p.copyWith(activeAnomaly: updatedAnomaly);
      HapticsService.triggerLightImpact();
      notifyListeners();
    }
  }

  /// Execute clinical workflow routing
  Future<void> routeActiveAnomaly({
    required String patientId,
    required List<String> recipients,
    bool hasVoiceNote = false,
    int voiceNoteDurationSeconds = 0,
    String? voiceNoteTranscript,
  }) async {
    final index = _patients.indexWhere((p) => p.id == patientId);
    if (index == -1) return;

    final patient = _patients[index];
    final anomaly = patient.activeAnomaly;
    if (anomaly == null) return;

    // 1. Determine routing payload via RoutingAgent
    final decision = aiEngine.routingAgent.determineRouting(
      anomaly: anomaly,
      patient: patient,
      selectedRecipients: recipients,
      hasVoiceNote: hasVoiceNote,
      voiceNoteDurationSeconds: voiceNoteDurationSeconds,
      voiceNoteTranscript: voiceNoteTranscript,
    );

    // 2. Transmit via Office Kit Bridge
    await officeKitBridge.transmitClinicalHandover(decision);

    // 3. Cryptographic Audit records
    aiEngine.auditAgent.recordEvent(
      eventType: 'EVENT_ROUTED',
      actor: aiEngine.routingAgent.agentId,
      actionSummary: 'Clinical alert routed to ${recipients.join(", ")} via Office Kit Bridge.',
      rawPayload: decision.toJson().toString(),
    );

    aiEngine.auditAgent.recordEvent(
      eventType: 'AUDIT_RECORD_CREATED',
      actor: aiEngine.auditAgent.agentId,
      actionSummary: 'Tamper-evident record sealed in local secure vault (Block #${aiEngine.auditAgent.records.length + 1}).',
      rawPayload: '{"decisionId": "${decision.id}", "sealed": true, "tamperProof": true}',
    );

    // 4. Update local secure vault storage
    await vaultService.saveSecureEntry(decision.id, decision.toJson().toString());

    // 5. Update patient and state
    final updatedAnomaly = anomaly.copyWith(
      isRouted: true,
      routedDestinations: recipients,
      routedAt: DateTime.now(),
    );

    _patients[index] = patient.copyWith(activeAnomaly: updatedAnomaly);
    _routingHistory.insert(0, decision);

    await HapticsService.triggerMediumImpact();
    notifyListeners();
  }

  @override
  void dispose() {
    _telemetryTimer?.cancel();
    super.dispose();
  }
}
