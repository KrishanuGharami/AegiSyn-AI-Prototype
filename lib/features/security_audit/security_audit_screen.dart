import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../services/app_state.dart';
import '../../widgets/audit_tile.dart';

class SecurityAuditScreen extends StatefulWidget {
  const SecurityAuditScreen({super.key});

  @override
  State<SecurityAuditScreen> createState() => _SecurityAuditScreenState();
}

class _SecurityAuditScreenState extends State<SecurityAuditScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _verifyIntegrity(AppState appState) {
    final isValid = appState.aiEngine.auditAgent.verifyChainIntegrity();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceElevated,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              isValid ? Icons.verified : Icons.warning_amber_rounded,
              color: isValid ? AppColors.vitalNormal : AppColors.alertHigh,
            ),
            const SizedBox(width: 8),
            Text(
              isValid ? 'Integrity Verified' : 'Integrity Failed',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
          ],
        ),
        content: Text(
          isValid
              ? 'All ${appState.auditRecords.length} cryptographic audit blocks in the SHA-256 Merkle chain have been recomputed and verified. Zero tampering detected.'
              : 'Cryptographic hash mismatch detected in audit chain!',
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.pulseCyan, foregroundColor: Colors.black),
            child: const Text('DISMISS'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final auditRecords = appState.auditRecords;
    final officeKit = appState.officeKitBridge;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Security & Audit Vault'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.pulseCyan,
          labelColor: AppColors.pulseCyan,
          unselectedLabelColor: AppColors.textMuted,
          tabs: const [
            Tab(text: 'Cryptographic Audit Trail'),
            Tab(text: 'iQOO Office Kit Status'),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Verify Cryptographic Integrity',
            icon: const Icon(Icons.security_update_good, color: AppColors.vitalNormal),
            onPressed: () => _verifyIntegrity(appState),
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAuditTrailTab(appState, auditRecords),
          _buildOfficeKitTab(appState, officeKit),
        ],
      ),
    );
  }

  Widget _buildAuditTrailTab(AppState appState, List<dynamic> auditRecords) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      children: [
        // Security Summary Card
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
                  const Icon(Icons.lock_clock, color: AppColors.vitalNormal, size: 18),
                  const SizedBox(width: 8),
                  const Text(
                    'TAMPER-EVIDENT MERKLE CHAIN',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.vitalNormalSoft,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${auditRecords.length} BLOCKS',
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.vitalNormal),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Every biometric anomaly, multi-agent AI classification, and clinical dispatch is cryptographically signed with SHA-256 and chained to prevent post-incident tampering.',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.35),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => _verifyIntegrity(appState),
                icon: const Icon(Icons.verified_user_outlined, size: 16, color: AppColors.vitalNormal),
                label: const Text(
                  'VERIFY CRYPTOGRAPHIC HASH CHAIN',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.vitalNormal),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.vitalNormal),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // 4 Core Demo Lifecycle Milestones Tracker
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.borderGlow),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'PRIMARY DEMO AUDIT MILESTONES',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.pulseCyan),
              ),
              const SizedBox(height: 10),
              _buildMilestoneRow(
                label: 'Event Detected',
                isCompleted: auditRecords.any((r) => r.eventType == 'EVENT_DETECTED'),
                icon: Icons.sensors,
              ),
              const SizedBox(height: 6),
              _buildMilestoneRow(
                label: 'AI Analysis Completed',
                isCompleted: auditRecords.any((r) => r.eventType == 'AI_ANALYSIS_COMPLETED'),
                icon: Icons.psychology,
              ),
              const SizedBox(height: 6),
              _buildMilestoneRow(
                label: 'Event Routed',
                isCompleted: auditRecords.any((r) => r.eventType == 'EVENT_ROUTED'),
                icon: Icons.alt_route,
              ),
              const SizedBox(height: 6),
              _buildMilestoneRow(
                label: 'Audit Record Created',
                isCompleted: auditRecords.any((r) => r.eventType == 'AUDIT_RECORD_CREATED'),
                icon: Icons.receipt_long,
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        const Text('RECORD BLOCKS (LATEST FIRST)', style: AppTypography.sectionHeader),
        const SizedBox(height: 10),

        ...auditRecords.reversed.map((record) => AuditTile(
              record: record,
              isLatest: record == auditRecords.last,
            )),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildMilestoneRow({
    required String label,
    required bool isCompleted,
    required IconData icon,
  }) {
    return Row(
      children: [
        Icon(
          isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
          size: 16,
          color: isCompleted ? AppColors.vitalNormal : AppColors.textMuted,
        ),
        const SizedBox(width: 8),
        Icon(icon, size: 14, color: isCompleted ? AppColors.textPrimary : AppColors.textMuted),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isCompleted ? FontWeight.w700 : FontWeight.w500,
            color: isCompleted ? AppColors.textPrimary : AppColors.textMuted,
          ),
        ),
        const Spacer(),
        Text(
          isCompleted ? 'CONFIRMED' : 'PENDING',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: isCompleted ? AppColors.vitalNormal : AppColors.textMuted,
          ),
        ),
      ],
    );
  }

  Widget _buildOfficeKitTab(AppState appState, dynamic officeKit) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      children: [
        // Mode & Peer Banner
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.officeKitBlue.withOpacity(0.5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.hub, color: AppColors.officeKitBlue, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'iQOO OFFICE KIT BRIDGE',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.officeKitBlue),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.officeKitBlueSoft,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      officeKit.isDevelopmentFallback ? 'DEMO SIMULATOR MODE' : 'NATIVE HARDWARE',
                      style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.officeKitBlue),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'Connected Peer: ${officeKit.peerDeviceName}',
                style: AppTypography.bodyEmphasized,
              ),
              const SizedBox(height: 4),
              const Text(
                'Cross-device multi-screen protocol allows physicians to triage anomalies on their iQOO smartphone and instantly project clinical waveforms and telemetry to hospital desktop workstations.',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.35),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        const Text('CAPABILITIES & EXTENDED WORKFLOW', style: AppTypography.sectionHeader),
        const SizedBox(height: 10),

        _buildCapabilityCard(
          title: 'Cross-Device Clinical Handover',
          description: 'Instant notification and patient telemetry packet transfer between mobile and workstation display.',
          isActive: officeKit.capabilities.instantClinicalHandover,
        ),
        const SizedBox(height: 8),
        _buildCapabilityCard(
          title: 'Multi-Screen Telemetry Mirroring',
          description: 'Low-latency live biometric waveform streaming directly to desktop monitor.',
          isActive: officeKit.capabilities.multiScreenMirroring,
        ),
        const SizedBox(height: 8),
        _buildCapabilityCard(
          title: 'Shared Clinical Clipboard & State',
          description: 'Synchronized patient queue and triage acknowledgements across hospital terminals.',
          isActive: officeKit.capabilities.crossDeviceClipboard,
        ),

        const SizedBox(height: 16),

        const Text('OFFICE KIT SYNC LOG (PACKET DUMP)', style: AppTypography.sectionHeader),
        const SizedBox(height: 10),

        ...officeKit.syncHistory.map((event) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.sync_alt, size: 14, color: AppColors.officeKitBlue),
                      const SizedBox(width: 6),
                      Text(
                        event.title,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                      ),
                      const Spacer(),
                      Text(
                        '${event.timestamp.hour}:${event.timestamp.minute.toString().padLeft(2, '0')}:${event.timestamp.second.toString().padLeft(2, '0')}',
                        style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(event.description, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      event.rawPacketDump,
                      style: AppTypography.codeMono.copyWith(fontSize: 10, color: AppColors.officeKitBlue),
                    ),
                  ),
                ],
              ),
            )),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildCapabilityCard({
    required String title,
    required String description,
    required bool isActive,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline, size: 18, color: isActive ? AppColors.vitalNormal : AppColors.textMuted),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.bodyEmphasized),
                const SizedBox(height: 2),
                Text(description, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
