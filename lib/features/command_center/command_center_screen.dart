import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../models/patient.dart';
import '../../services/app_state.dart';
import '../../widgets/waveform_painter.dart';
import '../../widgets/status_pill.dart';
import '../patient_detail/patient_detail_screen.dart';
import '../ai_analysis/ai_event_analysis_screen.dart';
import '../routing/alert_routing_screen.dart';
import '../security_audit/security_audit_screen.dart';
import '../bedside_scanner/bedside_scanner_modal.dart';

class CommandCenterScreen extends StatefulWidget {
  const CommandCenterScreen({super.key});

  @override
  State<CommandCenterScreen> createState() => _CommandCenterScreenState();
}

class _CommandCenterScreenState extends State<CommandCenterScreen> {
  int _currentNavIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: _buildCurrentTab(appState),
          ),
          bottomNavigationBar: _buildBottomNav(appState),
        );
      },
    );
  }

  Widget _buildCurrentTab(AppState appState) {
    switch (_currentNavIndex) {
      case 0:
        return _buildCommandCenterTab(appState);
      case 1:
        return PatientDetailScreen(patient: appState.selectedPatient);
      case 2:
        return AIEventAnalysisScreen(patient: appState.selectedPatient);
      case 3:
        return AlertRoutingScreen(patient: appState.selectedPatient);
      case 4:
        return const SecurityAuditScreen();
      default:
        return _buildCommandCenterTab(appState);
    }
  }

  Widget _buildCommandCenterTab(AppState appState) {
    final demoPatient = appState.demoPatient ?? appState.selectedPatient;
    final hasActiveAnomaly = demoPatient.activeAnomaly != null;
    final anomaly = demoPatient.activeAnomaly;

    return RefreshIndicator(
      onRefresh: () async {
        appState.toggleLiveStreaming();
      },
      color: AppColors.pulseCyan,
      backgroundColor: AppColors.surface,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        children: [
          // 1. BRAND HEADER & SYSTEM STATUS
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.pulseCyan, AppColors.aiViolet],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.pulseCyan.withOpacity(0.3),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: const Icon(Icons.shield_rounded, color: Colors.black, size: 24),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('AegiSyn AI', style: AppTypography.brandTitle),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.pulseCyanSoft,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppColors.pulseCyan.withOpacity(0.3)),
                        ),
                        child: const Text(
                          'iQOO 2026',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.pulseCyan),
                        ),
                      ),
                    ],
                  ),
                  const Text(
                    'HYDERABAD HEALTHTECH • CLINICAL COMMAND CENTER',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textMuted,
                      letterSpacing: 0.6,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // Bedside Optical Scanner Trigger (Phone Camera)
              InkWell(
                onTap: () {
                  BedsideScannerModal.show(context, appState, () {
                    setState(() => _currentNavIndex = 1);
                  });
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.pulseCyan.withOpacity(0.4)),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.qr_code_scanner, size: 13, color: AppColors.pulseCyan),
                      SizedBox(width: 4),
                      Text(
                        'SCAN',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.pulseCyan),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Streaming Pulse Dot
              InkWell(
                onTap: () => appState.toggleLiveStreaming(),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                  decoration: BoxDecoration(
                    color: appState.isLiveStreaming ? AppColors.vitalNormalSoft : AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: appState.isLiveStreaming ? AppColors.vitalNormal.withOpacity(0.4) : AppColors.borderSubtle,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: appState.isLiveStreaming ? AppColors.vitalNormal : AppColors.textMuted,
                          shape: BoxShape.circle,
                          boxShadow: appState.isLiveStreaming
                              ? [BoxShadow(color: AppColors.vitalNormal.withOpacity(0.6), blurRadius: 4)]
                              : null,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        appState.isLiveStreaming ? 'LIVE 25Hz' : 'PAUSED',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: appState.isLiveStreaming ? AppColors.vitalNormal : AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // 2. HARDWARE & PEER STATUS PILLS
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                const StatusPill(
                  label: 'Snapdragon NPU:',
                  value: '11.2ms (Edge AI)',
                  icon: Icons.memory,
                  statusColor: AppColors.vitalNormal,
                ),
                const SizedBox(width: 8),
                const StatusPill(
                  label: 'TrustZone Vault:',
                  value: 'Sealed',
                  icon: Icons.lock,
                  statusColor: AppColors.vitalNormal,
                ),
                const SizedBox(width: 8),
                StatusPill(
                  label: 'Office Kit:',
                  value: appState.officeKitBridge.connectionState.name.toUpperCase(),
                  icon: Icons.desktop_windows,
                  statusColor: AppColors.officeKitBlue,
                  onTap: () => setState(() => _currentNavIndex = 4),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 3. CLINICAL SIMULATION & STRESS CONTROLLER
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.surfaceHighlight.withOpacity(0.6),
                  AppColors.surface,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: appState.isDemoAnomalyActive ? AppColors.alertHigh.withOpacity(0.7) : AppColors.borderGlow,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.play_circle_filled_rounded,
                      size: 16,
                      color: appState.isDemoAnomalyActive ? AppColors.alertHigh : AppColors.pulseCyan,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'CLINICAL SIMULATION & VALIDATION (PATIENT #1048)',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.aiVioletSoft,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'CDS PROTOCOL',
                        style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.aiViolet),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      flex: 6,
                      child: ElevatedButton.icon(
                        onPressed: () => appState.triggerMultiSignalAnomalyDemo(),
                        icon: const Icon(Icons.warning_amber_rounded, size: 16),
                        label: const Text(
                          'TRIGGER MULTI-SIGNAL ANOMALY',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.alertHigh,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 4,
                      child: OutlinedButton.icon(
                        onPressed: () => appState.resetPatientToBaseline(),
                        icon: const Icon(Icons.refresh_rounded, size: 16, color: AppColors.vitalNormal),
                        label: const Text(
                          'RESET BASE',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.vitalNormal),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.vitalNormal),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 4. ACTIVE ALERT BANNER (If anomaly detected)
          if (hasActiveAnomaly && anomaly != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.alertHighSoft,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.alertHigh, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.alertHigh.withOpacity(0.25),
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
                        child: const Text(
                          'HIGH PRIORITY ALERT',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Patient #${demoPatient.displayId}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      // Phone Haptic Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceElevated,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppColors.alertHigh.withOpacity(0.4)),
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.vibration, size: 11, color: AppColors.alertHigh),
                            SizedBox(width: 4),
                            Text(
                              'HAPTICS PULSED',
                              style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.alertHigh),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Event: ${anomaly.eventType}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Reason: ${anomaly.primaryReason}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Action: ${anomaly.recommendedAction}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.alertWatch,
                    ),
                  ),
                  const SizedBox(height: 14),
                  // REVIEW BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        appState.selectPatient(demoPatient.id);
                        setState(() => _currentNavIndex = 2);
                      },
                      icon: const Icon(Icons.analytics_outlined, size: 18),
                      label: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text(
                            'REVIEW AI EVENT ANALYSIS',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                          ),
                          SizedBox(width: 6),
                          Icon(Icons.arrow_forward_rounded, size: 16),
                        ],
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.pulseCyan,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // 5. LIVE PATIENT TELEMETRY CARDS
          Row(
            children: [
              const Text(
                'MONITORED BEDS & LIVE TELEMETRY',
                style: AppTypography.sectionHeader,
              ),
              const Spacer(),
              InkWell(
                onTap: () {
                  BedsideScannerModal.show(context, appState, () {
                    setState(() => _currentNavIndex = 1);
                  });
                },
                child: Row(
                  children: const [
                    Icon(Icons.qr_code_scanner, size: 13, color: AppColors.pulseCyan),
                    SizedBox(width: 4),
                    Text(
                      'Scan Bed Tag',
                      style: TextStyle(fontSize: 12, color: AppColors.pulseCyan, fontWeight: FontWeight.w700),
                    ),
                    SizedBox(width: 10),
                  ],
                ),
              ),
              Text(
                '${appState.patients.length} Active Beds',
                style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 10),

          ...appState.patients.map((patient) => _buildPatientCard(patient, appState)),

          const SizedBox(height: 16),

          // 6. CRYPTOGRAPHIC AUDIT STREAM SUMMARY
          Row(
            children: [
              const Text(
                'IMMUTABLE ON-DEVICE AUDIT FEED',
                style: AppTypography.sectionHeader,
              ),
              const Spacer(),
              InkWell(
                onTap: () => setState(() => _currentNavIndex = 4),
                child: Row(
                  children: const [
                    Text(
                      'View All Blocks',
                      style: TextStyle(fontSize: 12, color: AppColors.pulseCyan, fontWeight: FontWeight.w700),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward, size: 12, color: AppColors.pulseCyan),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          ...appState.auditRecords.take(3).map((record) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.pulseCyan,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      record.eventType,
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.pulseCyan),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        record.actionSummary,
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Icon(Icons.verified, size: 12, color: AppColors.vitalNormal),
                  ],
                ),
              )),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildPatientCard(Patient patient, AppState appState) {
    final isSelected = patient.id == appState.selectedPatientId;
    final isAnomaly = patient.activeAnomaly != null;
    final current = patient.currentTelemetry;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isAnomaly
              ? AppColors.alertHigh.withOpacity(0.8)
              : (isSelected ? AppColors.pulseCyan.withOpacity(0.5) : AppColors.borderSubtle),
          width: isAnomaly ? 1.5 : 1.0,
        ),
      ),
      child: InkWell(
        onTap: () {
          appState.selectPatient(patient.id);
          setState(() => _currentNavIndex = 1);
        },
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Patient ID, Bed, Status
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isAnomaly ? AppColors.alertHighSoft : AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: isAnomaly ? AppColors.alertHigh.withOpacity(0.4) : AppColors.borderSubtle,
                      ),
                    ),
                    child: Text(
                      'BED #${patient.displayId}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: isAnomaly ? AppColors.alertHigh : AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      patient.ward,
                      style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isAnomaly ? AppColors.alertHigh : AppColors.vitalNormalSoft,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      isAnomaly ? 'HIGH ALERT' : 'STABLE',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: isAnomaly ? Colors.white : AppColors.vitalNormal,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Waveform with authentic ICU grid
              Container(
                height: 52,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CustomPaint(
                    painter: WaveformPainter(
                      history: patient.telemetryHistory,
                      lineColor: isAnomaly ? AppColors.alertHigh : AppColors.pulseCyan,
                      showGrid: true,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // 4 Vital Parameter Readouts
              Row(
                children: [
                  _buildQuickVital(
                    label: 'HR',
                    value: '${current.heartRate.round()}',
                    unit: 'bpm',
                    isAlert: isAnomaly && current.heartRate > 100,
                  ),
                  _buildQuickVital(
                    label: 'SpO2',
                    value: '${current.spO2.round()}',
                    unit: '%',
                    isAlert: isAnomaly && current.spO2 < 92,
                  ),
                  _buildQuickVital(
                    label: 'RESP',
                    value: '${current.respirationRate.round()}',
                    unit: 'rpm',
                    isAlert: isAnomaly && current.respirationRate > 22,
                  ),
                  _buildQuickVital(
                    label: 'BP',
                    value: current.bloodPressureString,
                    unit: 'mmHg',
                    isAlert: false,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickVital({
    required String label,
    required String value,
    required String unit,
    required bool isAlert,
  }) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: isAlert ? AppColors.alertHigh : AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: isAlert ? AppColors.alertHigh : AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 2),
              Text(
                unit,
                style: const TextStyle(fontSize: 9, color: AppColors.textMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(AppState appState) {
    return BottomNavigationBar(
      currentIndex: _currentNavIndex,
      onTap: (index) => setState(() => _currentNavIndex = index),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard_outlined),
          activeIcon: Icon(Icons.dashboard),
          label: 'Command',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite_outline),
          activeIcon: Icon(Icons.favorite),
          label: 'Vitals',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.psychology_outlined),
          activeIcon: Icon(Icons.psychology),
          label: 'AI Analysis',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.alt_route_rounded),
          activeIcon: Icon(Icons.alt_route_rounded),
          label: 'Routing',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.verified_user_outlined),
          activeIcon: Icon(Icons.verified_user),
          label: 'Security',
        ),
      ],
    );
  }
}
