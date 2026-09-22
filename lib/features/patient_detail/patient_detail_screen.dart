import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../models/patient.dart';
import '../../services/app_state.dart';
import '../../widgets/waveform_painter.dart';
import '../../widgets/vital_metric_tile.dart';
import '../ai_analysis/ai_event_analysis_screen.dart';

class PatientDetailScreen extends StatelessWidget {
  final Patient patient;

  const PatientDetailScreen({
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
    final telemetry = currentPatient.currentTelemetry;
    final base = currentPatient.baselineTelemetry;
    final isAnomaly = currentPatient.activeAnomaly != null;
    final clinicalLogs = appState.aiEngine.clinicalLogAgent.extractContextualNotes(currentPatient.id);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Bed #${currentPatient.displayId} Telemetry Detail'),
        actions: [
          IconButton(
            tooltip: 'Toggle Live 25Hz Ingestion',
            icon: Icon(
              appState.isLiveStreaming ? Icons.sensors : Icons.sensors_off,
              color: appState.isLiveStreaming ? AppColors.vitalNormal : AppColors.textMuted,
            ),
            onPressed: () => appState.toggleLiveStreaming(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // Patient Demographic Card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.person, color: AppColors.pulseCyan, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Synthetic Patient ${currentPatient.displayId}',
                            style: AppTypography.bodyEmphasized,
                          ),
                          Text(
                            '${currentPatient.age} yrs • ${currentPatient.gender} • ${currentPatient.ward}',
                            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isAnomaly ? AppColors.alertHigh : AppColors.vitalNormalSoft,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isAnomaly ? 'HIGH ALERT' : 'STABLE',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: isAnomaly ? Colors.white : AppColors.vitalNormal,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Admission: ${currentPatient.admissionReason}',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // High Priority Alert Banner (If present)
          if (isAnomaly) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.alertHighSoft,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.alertHigh),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.warning_rounded, color: AppColors.alertHigh, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        currentPatient.activeAnomaly!.eventType,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.alertHigh,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'HIGH',
                          style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Reason: ${currentPatient.activeAnomaly!.primaryReason}',
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Action: ${currentPatient.activeAnomaly!.recommendedAction}',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.alertWatch),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => AIEventAnalysisScreen(patient: currentPatient),
                          ),
                        );
                      },
                      icon: const Icon(Icons.psychology_outlined, size: 16),
                      label: const Text('REVIEW MULTI-AGENT ANALYSIS'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.pulseCyan,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],

          // Real-time Physiological Waveform Monitor
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.show_chart, color: AppColors.pulseCyan, size: 16),
                    const SizedBox(width: 6),
                    const Text(
                      'CONTINUOUS BIOMETRIC WAVEFORM (LEAD II)',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.textSecondary),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Live 30s Buffer',
                        style: TextStyle(fontSize: 9, color: AppColors.textMuted, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  height: 130,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.borderSubtle),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: CustomPaint(
                      painter: WaveformPainter(
                        history: currentPatient.telemetryHistory,
                        lineColor: isAnomaly ? AppColors.alertHigh : AppColors.pulseCyan,
                        showGrid: true,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Vitals Grid (HR, SpO2, Resp, BP)
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.6,
            children: [
              VitalMetricTile(
                label: 'Heart Rate',
                value: '${telemetry.heartRate.round()}',
                unit: 'bpm',
                icon: Icons.favorite,
                accentColor: AppColors.pulseCyan,
                isAbnormal: isAnomaly && telemetry.heartRate > 100,
                deltaSubtitle: 'Base: ${base.heartRate.round()} bpm',
              ),
              VitalMetricTile(
                label: 'SpO2 Oxygen',
                value: '${telemetry.spO2.round()}',
                unit: '%',
                icon: Icons.bloodtype,
                accentColor: AppColors.vitalNormal,
                isAbnormal: isAnomaly && telemetry.spO2 < 92,
                deltaSubtitle: 'Base: ${base.spO2.round()}%',
              ),
              VitalMetricTile(
                label: 'Respiration',
                value: '${telemetry.respirationRate.round()}',
                unit: 'rpm',
                icon: Icons.air,
                accentColor: AppColors.aiViolet,
                isAbnormal: isAnomaly && telemetry.respirationRate > 22,
                deltaSubtitle: 'Base: ${base.respirationRate.round()} rpm',
              ),
              VitalMetricTile(
                label: 'Blood Pressure',
                value: telemetry.bloodPressureString,
                unit: 'mmHg',
                icon: Icons.speed,
                accentColor: AppColors.officeKitBlue,
                isAbnormal: isAnomaly && telemetry.systolicBp > 140,
                deltaSubtitle: 'Base: ${base.bloodPressureString}',
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Clinical Shift Notes Timeline
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'CLINICAL SHIFT TIMELINE (EHR CONTEXT)',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 10),
                ...clinicalLogs.map((log) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: AppColors.pulseCyan,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  log.actor,
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  log.content,
                                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
