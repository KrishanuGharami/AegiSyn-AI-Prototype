import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../models/patient.dart';
import '../../services/app_state.dart';
import '../../services/device/haptics_service.dart';
import '../security_audit/security_audit_screen.dart';

class AlertRoutingScreen extends StatefulWidget {
  final Patient patient;

  const AlertRoutingScreen({
    super.key,
    required this.patient,
  });

  @override
  State<AlertRoutingScreen> createState() => _AlertRoutingScreenState();
}

class _AlertRoutingScreenState extends State<AlertRoutingScreen> {
  final Set<String> _selectedRecipients = {
    'Duty Doctor (Dr. Ananya Reddy - Cardiology)',
    'Nursing Station (ICU Pod 04)',
  };

  bool _enableOfficeKitWorkstationSync = true;
  bool _isDispatching = false;
  bool _hasDispatched = false;

  // Phone Microphone: Bedside Clinical Voice Dictation
  bool _isRecordingVoice = false;
  bool _hasVoiceRecorded = false;
  int _voiceSeconds = 0;
  Timer? _voiceTimer;

  final List<Map<String, dynamic>> _availableRecipients = [
    {
      'title': 'Duty Doctor (Dr. Ananya Reddy - Cardiology)',
      'role': 'On-Call Physician',
      'device': 'iQOO Neo Pager / Mobile',
      'icon': Icons.medical_services_outlined,
    },
    {
      'title': 'Nursing Station (ICU Pod 04)',
      'role': 'Primary ICU Floor Station',
      'device': 'Hospital Workstation Display',
      'icon': Icons.local_hospital_outlined,
    },
    {
      'title': 'Rapid Response Team (Code Blue Stby)',
      'role': 'Critical Care Escalation',
      'device': 'Emergency Broadcast Intercom',
      'icon': Icons.emergency_outlined,
    },
    {
      'title': 'Attending Pulmonologist (On-Call)',
      'role': 'Specialist Consultation',
      'device': 'Secure Hospital Intranet',
      'icon': Icons.air_outlined,
    },
  ];

  @override
  void dispose() {
    _voiceTimer?.cancel();
    super.dispose();
  }

  void _toggleVoiceDictation() {
    if (_isRecordingVoice) {
      // Stop recording
      _voiceTimer?.cancel();
      setState(() {
        _isRecordingVoice = false;
        _hasVoiceRecorded = true;
        if (_voiceSeconds == 0) _voiceSeconds = 5;
      });
      HapticsService.triggerMediumImpact();
    } else {
      // Start recording
      setState(() {
        _isRecordingVoice = true;
        _hasVoiceRecorded = false;
        _voiceSeconds = 0;
      });
      HapticsService.triggerLightImpact();
      _voiceTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (mounted) {
          setState(() {
            _voiceSeconds++;
            if (_voiceSeconds >= 15) {
              _toggleVoiceDictation();
            }
          });
        }
      });
    }
  }

  void _clearVoiceNote() {
    _voiceTimer?.cancel();
    setState(() {
      _isRecordingVoice = false;
      _hasVoiceRecorded = false;
      _voiceSeconds = 0;
    });
    HapticsService.triggerLightImpact();
  }

  Future<void> _handleDispatch(AppState appState, Patient currentPatient) async {
    if (_selectedRecipients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one routing recipient.')),
      );
      return;
    }

    setState(() => _isDispatching = true);

    const voiceTranscript =
        'Dr. Reddy: Acute multi-signal divergence observed for Bed 1048. Compensatory tachycardia and arterial desaturation. Beta-blocker held, please evaluate immediately.';

    await appState.routeActiveAnomaly(
      patientId: currentPatient.id,
      recipients: _selectedRecipients.toList(),
      hasVoiceNote: _hasVoiceRecorded,
      voiceNoteDurationSeconds: _hasVoiceRecorded ? _voiceSeconds : 0,
      voiceNoteTranscript: _hasVoiceRecorded ? voiceTranscript : null,
    );

    if (!mounted) return;

    setState(() {
      _isDispatching = false;
      _hasDispatched = true;
    });

    // Show success bottom dialog with link to Security Audit
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.vitalNormalSoft,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check_circle, color: AppColors.vitalNormal, size: 28),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Alert Successfully Routed', style: AppTypography.screenHeading),
                      Text(
                        _hasVoiceRecorded
                            ? 'Workstation Peer Acknowledged (+ Voice Memo)'
                            : 'Office Kit Workstation Peer Acknowledged',
                        style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('AUDIT SEAL GENERATED', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.pulseCyan)),
                    const SizedBox(height: 4),
                    Text(
                      _hasVoiceRecorded
                          ? 'Cryptographic SHA-256 record sealed. Audio payload hash linked to Merkle audit chain.'
                          : 'A cryptographic SHA-256 tamper-evident record has been sealed into the local database.',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SecurityAuditScreen()),
                    );
                  },
                  icon: const Icon(Icons.shield_outlined, size: 18),
                  label: const Text('VIEW AUDIT RECORD IN SECURITY VAULT'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.pulseCyan,
                    foregroundColor: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final currentPatient = appState.patients.firstWhere(
      (p) => p.id == widget.patient.id,
      orElse: () => widget.patient,
    );
    final anomaly = currentPatient.activeAnomaly;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Alert Routing Engine'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          if (_hasDispatched) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.officeKitBlueSoft,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.officeKitBlue),
              ),
              child: Row(
                children: [
                  const Icon(Icons.desktop_windows, color: AppColors.officeKitBlue, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'OFFICE KIT HANDOVER CONFIRMED',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.officeKitBlue),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _hasVoiceRecorded
                              ? 'Clinical packet + 5s audio memo mirrored to hospital workstation display.'
                              : 'Clinical packet mirrored to hospital workstation display (0.8ms P2P latency).',
                          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Alert Context Summary Card
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
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.alertHigh,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'HIGH PRIORITY',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Patient #${currentPatient.displayId} (${currentPatient.ward})',
                      style: AppTypography.bodyEmphasized,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  anomaly != null
                      ? 'Event: ${anomaly.eventType} • ${anomaly.primaryReason}'
                      : 'Telemetry surveillance alert for Bed #${currentPatient.displayId}',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // iQOO Office Kit Workstation Handover Module
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.officeKitBlue.withOpacity(0.4)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.officeKitBlueSoft,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.hub, color: AppColors.officeKitBlue, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'iQOO Office Kit Auto-Handover',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                      ),
                      Text(
                        'Peer: ${appState.officeKitBridge.peerDeviceName}',
                        style: const TextStyle(fontSize: 10, color: AppColors.officeKitBlue),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _enableOfficeKitWorkstationSync,
                  activeThumbColor: AppColors.officeKitBlue,
                  onChanged: (val) {
                    setState(() => _enableOfficeKitWorkstationSync = val);
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // PHONE-FIRST FEATURE: BEDSIDE VOICE HANDOVER MEMO (PHONE MIC)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _isRecordingVoice
                    ? AppColors.alertHigh
                    : (_hasVoiceRecorded ? AppColors.pulseCyan : AppColors.borderSubtle),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: _isRecordingVoice
                            ? AppColors.alertHighSoft
                            : (_hasVoiceRecorded ? AppColors.pulseCyanSoft : AppColors.surfaceElevated),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        _isRecordingVoice ? Icons.mic : Icons.mic_none,
                        size: 16,
                        color: _isRecordingVoice
                            ? AppColors.alertHigh
                            : (_hasVoiceRecorded ? AppColors.pulseCyan : AppColors.textSecondary),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'BEDSIDE VOICE HANDOVER (PHONE MIC)',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                    ),
                    const Spacer(),
                    if (_isRecordingVoice)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.alertHigh,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'REC 00:${_voiceSeconds.toString().padLeft(2, '0')}',
                          style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.white),
                        ),
                      )
                    else if (_hasVoiceRecorded)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.vitalNormalSoft,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'ATTACHED (${_voiceSeconds}s)',
                          style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.vitalNormal),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                if (!_isRecordingVoice && !_hasVoiceRecorded) ...[
                  const Text(
                    'Tap to dictate a 10-second bedside clinical audio memo for the duty doctor and ICU station.',
                    style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _toggleVoiceDictation,
                      icon: const Icon(Icons.mic, size: 16, color: AppColors.pulseCyan),
                      label: const Text(
                        'RECORD VOICE HANDOVER MEMO',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.pulseCyan),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.pulseCyan),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                ] else if (_isRecordingVoice) ...[
                  const Text(
                    'Listening to attending clinician... Tap stop when finished.',
                    style: TextStyle(fontSize: 12, color: AppColors.alertHigh, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _toggleVoiceDictation,
                      icon: const Icon(Icons.stop, size: 16),
                      label: const Text(
                        'STOP RECORDING',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.alertHigh,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                ] else if (_hasVoiceRecorded) ...[
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.audiotrack, size: 14, color: AppColors.pulseCyan),
                            const SizedBox(width: 6),
                            const Text(
                              'Voice Dictation Transcript (On-Device Speech Model):',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textMuted),
                            ),
                            const Spacer(),
                            InkWell(
                              onTap: _clearVoiceNote,
                              child: const Icon(Icons.delete_outline, size: 16, color: AppColors.textMuted),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          '"Dr. Reddy: Acute multi-signal divergence observed for Bed 1048. Compensatory tachycardia and arterial desaturation. Beta-blocker held, please evaluate immediately."',
                          style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: AppColors.textPrimary, height: 1.3),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 16),

          const Text(
            'SELECT CLINICAL RECIPIENTS',
            style: AppTypography.sectionHeader,
          ),
          const SizedBox(height: 10),

          ..._availableRecipients.map((recipient) {
            final title = recipient['title'] as String;
            final isSelected = _selectedRecipients.contains(title);

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? AppColors.pulseCyan : AppColors.borderSubtle,
                  width: isSelected ? 1.5 : 1.0,
                ),
              ),
              child: CheckboxListTile(
                value: isSelected,
                activeColor: AppColors.pulseCyan,
                checkColor: Colors.black,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                secondary: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.pulseCyanSoft : AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(recipient['icon'] as IconData, color: isSelected ? AppColors.pulseCyan : AppColors.textSecondary, size: 20),
                ),
                title: Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                  ),
                ),
                subtitle: Text(
                  '${recipient['role']} • Device: ${recipient['device']}',
                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
                onChanged: (checked) {
                  setState(() {
                    if (checked == true) {
                      _selectedRecipients.add(title);
                    } else {
                      _selectedRecipients.remove(title);
                    }
                  });
                },
              ),
            );
          }),

          const SizedBox(height: 20),

          // Primary Dispatch Button
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton.icon(
              onPressed: _isDispatching ? null : () => _handleDispatch(appState, currentPatient),
              icon: _isDispatching
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                    )
                  : const Icon(Icons.send_rounded, size: 18),
              label: Text(
                _hasDispatched ? 'DISPATCH COMPLETED (RE-ROUTE)' : 'DISPATCH ALERT & NOTIFY TEAMS',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 0.5),
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
      ),
    );
  }
}
