import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../models/patient.dart';
import '../../models/anomaly_event.dart';
import '../../services/app_state.dart';
import '../routing/alert_routing_screen.dart';

class AIEventAnalysisScreen extends StatelessWidget {
  final Patient patient;

  const AIEventAnalysisScreen({
    super.key,
    required this.patient,
  });

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final currentPatient = appState.patients.firstWhere(
      (p) => p.id == patient.id,
      orElse: () => patient,
    );
    final anomaly = currentPatient.activeAnomaly;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('AI Event Analysis'),
      ),
      body: anomaly == null
          ? _buildNormalSurveillanceView(context, appState)
          : _buildAnalysisView(context, appState, currentPatient, anomaly),
    );
  }

  Widget _buildNormalSurveillanceView(BuildContext context, AppState appState) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: const Icon(Icons.verified_user_outlined, size: 48, color: AppColors.vitalNormal),
            ),
            const SizedBox(height: 18),
            const Text(
              'Biometric Signals Within Expected Limits',
              style: AppTypography.screenHeading,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Autonomous on-device edge surveillance active. No multi-signal correlation divergence detected for this patient.',
              style: AppTypography.bodyRegular,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => appState.triggerMultiSignalAnomalyDemo(),
              icon: const Icon(Icons.bolt, size: 18),
              label: const Text('SIMULATE DEMO ANOMALY'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.alertHigh,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisView(
    BuildContext context,
    AppState appState,
    Patient currentPatient,
    AnomalyEvent anomaly,
  ) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      children: [
        // 1. PRIMARY EVENT CLASSIFICATION BANNER
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.alertHighSoft,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.alertHigh, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: AppColors.alertHigh.withOpacity(0.2),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.alertHigh,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      anomaly.severity.label,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Bed #${currentPatient.displayId} • ${currentPatient.ward}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'LOCAL NPU INFERENCE',
                      style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.pulseCyan),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Event: ${anomaly.eventType}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Priority: ',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  ),
                  Text(
                    anomaly.severity.label,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.alertHigh),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Correlation Index: ',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  ),
                  Text(
                    '${(anomaly.confidenceScore * 100).round()}% (High)',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.pulseCyan),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Reason: ',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  ),
                  Expanded(
                    child: Text(
                      anomaly.primaryReason,
                      style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Action: ',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  ),
                  Expanded(
                    child: Text(
                      anomaly.recommendedAction,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.alertWatch),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // 2. CONCURRENT DIVERGENCE BREAKDOWN CARDS
        const Text(
          'CONCURRENT BIOMETRIC DEVIATIONS',
          style: AppTypography.sectionHeader,
        ),
        const SizedBox(height: 10),

        _buildDeviationCard(
          parameter: 'Heart Rate (Tachycardia)',
          observedValue: '128 bpm',
          baselineRange: 'Normal: 60–100 bpm (Base: 74)',
          divergenceNote: '+54 bpm acute elevation',
          icon: Icons.favorite,
          isCritical: true,
        ),
        const SizedBox(height: 8),
        _buildDeviationCard(
          parameter: 'SpO2 Oxygen (Desaturation)',
          observedValue: '89 %',
          baselineRange: 'Normal: 95–100 % (Base: 98)',
          divergenceNote: '-9% acute desaturation',
          icon: Icons.bloodtype,
          isCritical: true,
        ),
        const SizedBox(height: 8),
        _buildDeviationCard(
          parameter: 'Respiration Rate (Tachypnea)',
          observedValue: '28 rpm',
          baselineRange: 'Normal: 12–20 rpm (Base: 16)',
          divergenceNote: '+12 rpm hyperventilation',
          icon: Icons.air,
          isCritical: true,
        ),

        const SizedBox(height: 16),

        // 3. MULTI-AGENT PERCEPTION PIPELINE
        const Text(
          'ON-DEVICE MULTI-AGENT PIPELINE',
          style: AppTypography.sectionHeader,
        ),
        const SizedBox(height: 10),

        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Column(
            children: [
              _buildAgentNode(
                agentName: 'SignalAgent',
                role: 'Signal Ingestion & Delta Conditioning',
                status: 'Deviations confirmed across 3 monitored channels',
              ),
              const Divider(color: AppColors.borderSubtle, height: 16),
              _buildAgentNode(
                agentName: 'ClinicalLogAgent',
                role: 'Contextual EHR Timeline Correlation',
                status: 'Verified no conflicting beta-blocker/sedative timing',
              ),
              const Divider(color: AppColors.borderSubtle, height: 16),
              _buildAgentNode(
                agentName: 'AnomalyAgent',
                role: 'Multi-Signal Correlation Engine',
                status: 'Cross-axis correlation coefficient 0.94 -> High Priority',
              ),
              const Divider(color: AppColors.borderSubtle, height: 16),
              _buildAgentNode(
                agentName: 'RoutingAgent',
                role: 'Clinical Decision Workflow Triage',
                status: 'Targets: Duty Doctor (Cardiology) + Nursing Station',
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // 4. EDGE AI HARDWARE TELEMETRY
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderGlow),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildHardwareStat('Execution Engine', 'Snapdragon NPU / Edge'),
              _buildHardwareStat('Inference Latency', '11.2 ms'),
              _buildHardwareStat('Cloud Data Egress', '0 Bytes (100% Local)'),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Safety & Clinical Decision Support Notice
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Row(
            children: const [
              Icon(Icons.shield_outlined, size: 14, color: AppColors.alertWatch),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Clinical Decision Support • Designed around privacy-by-design principles • Synthetic data model',
                  style: TextStyle(fontSize: 10, color: AppColors.textMuted, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // 5. ROUTE ACTION BUTTON (PRIMARY DEMO CTA)
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => AlertRoutingScreen(patient: currentPatient),
                ),
              );
            },
            icon: const Icon(Icons.alt_route_rounded, size: 20),
            label: const Text(
              'ROUTE ALERT TO CLINICAL WORKFLOW',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 0.5),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.pulseCyan,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildDeviationCard({
    required String parameter,
    required String observedValue,
    required String baselineRange,
    required String divergenceNote,
    required IconData icon,
    required bool isCritical,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isCritical ? AppColors.alertHigh.withOpacity(0.5) : AppColors.borderSubtle),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.alertHighSoft,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.alertHigh, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(parameter, style: AppTypography.bodyEmphasized),
                const SizedBox(height: 2),
                Text(baselineRange, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                observedValue,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.alertHigh),
              ),
              const SizedBox(height: 2),
              Text(
                divergenceNote,
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.alertWatch),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAgentNode({
    required String agentName,
    required String role,
    required String status,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.pulseCyanSoft,
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Icon(Icons.memory, size: 14, color: AppColors.pulseCyan),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(agentName, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                  const SizedBox(width: 6),
                  Text('($role)', style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                status,
                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        const Icon(Icons.check_circle, size: 16, color: AppColors.vitalNormal),
      ],
    );
  }

  Widget _buildHardwareStat(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.pulseCyan),
        ),
      ],
    );
  }
}
