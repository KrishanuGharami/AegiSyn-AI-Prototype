import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../services/app_state.dart';
import '../../services/device/haptics_service.dart';

class BedsideScannerModal extends StatefulWidget {
  final AppState appState;
  final VoidCallback onPatientIdentified;

  const BedsideScannerModal({
    super.key,
    required this.appState,
    required this.onPatientIdentified,
  });

  static Future<void> show(BuildContext context, AppState appState, VoidCallback onIdentified) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BedsideScannerModal(
        appState: appState,
        onPatientIdentified: onIdentified,
      ),
    );
  }

  @override
  State<BedsideScannerModal> createState() => _BedsideScannerModalState();
}

class _BedsideScannerModalState extends State<BedsideScannerModal> with SingleTickerProviderStateMixin {
  late AnimationController _laserController;
  bool _isAcquiring = true;
  bool _isLocked = false;
  final String _targetPatientId = 'PAT-1048';
  Timer? _lockTimer;

  @override
  void initState() {
    super.initState();
    _laserController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    // Simulate optical barcode/tag lock after 1.6 seconds
    _lockTimer = Timer(const Duration(milliseconds: 1600), () {
      if (mounted) {
        setState(() {
          _isAcquiring = false;
          _isLocked = true;
        });
        HapticsService.triggerLightImpact();

        // Record optical acquisition in the audit trail
        widget.appState.aiEngine.auditAgent.recordEvent(
          eventType: 'BEDSIDE_OPTICAL_SCAN',
          actor: 'PhoneCameraPerception',
          actionSummary: 'Bedside wristband tag scanned via phone optical perception: Bed #1048.',
          rawPayload: '{"tag": "QR_BARCODE_PAT1048", "confidence": 0.99, "scanner": "AegiSynOpticalEngine"}',
        );

        // Auto dismiss after brief confirmation
        Future.delayed(const Duration(milliseconds: 900), () {
          if (mounted) {
            widget.appState.selectPatient(_targetPatientId);
            Navigator.of(context).pop();
            widget.onPatientIdentified();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _laserController.dispose();
    _lockTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.78,
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.pulseCyanSoft,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.qr_code_scanner, color: AppColors.pulseCyan, size: 20),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Bedside Optical Perception', style: AppTypography.screenHeading),
                    Text('Point camera at patient wristband or telemetry tag', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                  ],
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.textMuted),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          const Divider(color: AppColors.borderSubtle, height: 1),

          // Scanner Viewfinder Area
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Viewfinder Frame
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _isLocked ? AppColors.vitalNormal : AppColors.pulseCyan,
                        width: 2.0,
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _isLocked ? Icons.check_circle : Icons.person_pin,
                            size: 64,
                            color: _isLocked ? AppColors.vitalNormal : AppColors.textMuted.withOpacity(0.5),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _isLocked
                                ? 'PATIENT #1048 IDENTIFIED'
                                : 'ALIGNING BEDSIDE WRISTBAND...',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: _isLocked ? AppColors.vitalNormal : AppColors.textSecondary,
                              letterSpacing: 0.6,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _isLocked
                                ? 'ICU Pod 04 • Thoracic Telemetry Bed'
                                : 'Optical character & QR decoding active',
                            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Animated Laser Scanner Line
                  if (_isAcquiring)
                    AnimatedBuilder(
                      animation: _laserController,
                      builder: (context, child) {
                        return Positioned(
                          top: 40 + (_laserController.value * 260),
                          left: 20,
                          right: 20,
                          child: Container(
                            height: 2.5,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Colors.transparent, AppColors.pulseCyan, Colors.transparent],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.pulseCyan.withOpacity(0.7),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                  // Corner Reticle Markers
                  Positioned(
                    top: 14,
                    left: 14,
                    child: _buildCorner(isTop: true, isLeft: true),
                  ),
                  Positioned(
                    top: 14,
                    right: 14,
                    child: _buildCorner(isTop: true, isLeft: false),
                  ),
                  Positioned(
                    bottom: 14,
                    left: 14,
                    child: _buildCorner(isTop: false, isLeft: true),
                  ),
                  Positioned(
                    bottom: 14,
                    right: 14,
                    child: _buildCorner(isTop: false, isLeft: false),
                  ),
                ],
              ),
            ),
          ),

          // Footer Information
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderGlow),
              ),
              child: Row(
                children: const [
                  Icon(Icons.camera_alt_outlined, size: 16, color: AppColors.pulseCyan),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Camera optical perception binds physical bedside wristbands to local encrypted telemetry without cloud lookups.',
                      style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCorner({required bool isTop, required bool isLeft}) {
    final color = _isLocked ? AppColors.vitalNormal : AppColors.pulseCyan;
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        border: Border(
          top: isTop ? BorderSide(color: color, width: 3) : BorderSide.none,
          bottom: !isTop ? BorderSide(color: color, width: 3) : BorderSide.none,
          left: isLeft ? BorderSide(color: color, width: 3) : BorderSide.none,
          right: !isLeft ? BorderSide(color: color, width: 3) : BorderSide.none,
        ),
      ),
    );
  }
}
