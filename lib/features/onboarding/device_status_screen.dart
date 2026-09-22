import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../command_center/command_center_screen.dart';

class DeviceStatusScreen extends StatefulWidget {
  const DeviceStatusScreen({super.key});

  @override
  State<DeviceStatusScreen> createState() => _DeviceStatusScreenState();
}

class _DeviceStatusScreenState extends State<DeviceStatusScreen> {
  bool _isInitializing = false;

  void _enterCommandCenter() {
    setState(() => _isInitializing = true);
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const CommandCenterScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              // Brand & Track Header
              Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.pulseCyan, AppColors.aiViolet],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.pulseCyan.withOpacity(0.35),
                          blurRadius: 14,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.shield_rounded, color: Colors.black, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('AegiSyn AI', style: AppTypography.brandTitle),
                        Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: AppColors.pulseCyan,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'HYDERABAD HEALTHTECH • iQOO 2026',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: AppColors.pulseCyan,
                                letterSpacing: 0.6,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 22),
              const Text(
                'Clinical Perception & Hardware Verification',
                style: AppTypography.screenHeading,
              ),
              const SizedBox(height: 6),
              const Text(
                'Local multi-agent neural perception is initialized on this device. All biometric telemetry is processed autonomously with zero cloud exfiltration.',
                style: AppTypography.bodyRegular,
              ),

              const SizedBox(height: 18),

              // Hardware Status Checklist
              Expanded(
                child: ListView(
                  children: [
                    _buildStatusItem(
                      icon: Icons.memory,
                      title: 'Qualcomm NPU / Edge Runtime',
                      description: 'On-device neural inference active • 11.2ms latency',
                      statusBadge: 'ONLINE',
                      badgeColor: AppColors.vitalNormal,
                    ),
                    const SizedBox(height: 10),
                    _buildStatusItem(
                      icon: Icons.security,
                      title: 'ARM TrustZone Cryptographic Vault',
                      description: 'SHA-256 Merkle chain integrity active • Encrypted storage',
                      statusBadge: 'SEALED',
                      badgeColor: AppColors.vitalNormal,
                    ),
                    const SizedBox(height: 10),
                    _buildStatusItem(
                      icon: Icons.hub,
                      title: 'iQOO Office Kit Bridge',
                      description: 'Paired with ICU Workstation #04 • LAN/BLE Protocol v2.4',
                      statusBadge: 'CONNECTED',
                      badgeColor: AppColors.officeKitBlue,
                    ),
                    const SizedBox(height: 10),
                    _buildStatusItem(
                      icon: Icons.vibration,
                      title: 'Tactical Linear Motor Haptics',
                      description: 'Dual-pulse emergency tactile alarm ready for critical divergence',
                      statusBadge: 'ACTIVE',
                      badgeColor: AppColors.vitalNormal,
                    ),
                    const SizedBox(height: 10),
                    _buildStatusItem(
                      icon: Icons.sensors,
                      title: 'Biometric Telemetry Ingestion',
                      description: '25Hz multi-lead physiological stream conditioning',
                      statusBadge: '4 BEDS ACTIVE',
                      badgeColor: AppColors.vitalNormal,
                    ),

                    const SizedBox(height: 16),

                    // Regulatory & Safety Disclaimer
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.borderGlow),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.info_outline, size: 18, color: AppColors.alertWatch),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'CLINICAL DECISION SUPPORT SPECIFICATION',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.alertWatch,
                                    letterSpacing: 0.6,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'AegiSyn AI provides decision support, multi-signal anomaly detection, and workflow prioritization. It does not provide medical diagnosis or replace physician clinical judgment. Monitored records utilize synthetic patient data models.',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textSecondary,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Action Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isInitializing ? null : _enterCommandCenter,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.pulseCyan,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _isInitializing
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.black),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Text(
                              'LAUNCH CLINICAL COMMAND CENTER',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward_rounded, size: 18),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusItem({
    required IconData icon,
    required String title,
    required String description,
    required String statusBadge,
    required Color badgeColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: badgeColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: badgeColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.bodyEmphasized),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: badgeColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: badgeColor.withOpacity(0.4)),
            ),
            child: Text(
              statusBadge,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: badgeColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
