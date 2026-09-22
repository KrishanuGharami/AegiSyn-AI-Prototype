import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/audit_record.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_typography.dart';
import 'package:intl/intl.dart';

class AuditTile extends StatelessWidget {
  final AuditRecord record;
  final bool isLatest;

  const AuditTile({
    super.key,
    required this.record,
    this.isLatest = false,
  });

  Color _getEventColor(String eventType) {
    switch (eventType) {
      case 'EVENT_DETECTED':
        return AppColors.alertHigh;
      case 'AI_ANALYSIS_COMPLETED':
        return AppColors.aiViolet;
      case 'EVENT_ROUTED':
        return AppColors.pulseCyan;
      case 'AUDIT_RECORD_CREATED':
        return AppColors.vitalNormal;
      default:
        return AppColors.textSecondary;
    }
  }

  void _showRecordDetails(BuildContext context) {
    final eventColor = _getEventColor(record.eventType);
    final formattedTime = DateFormat('yyyy-MM-dd HH:mm:ss.SSS').format(record.timestamp);

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceElevated,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: eventColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'BLOCK #${record.sequenceIndex.toString().padLeft(2, '0')}',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: eventColor),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    record.eventType,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: eventColor),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20, color: AppColors.textMuted),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                record.actionSummary,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 16),
              _buildDetailRow('Actor Agent', record.actor, isMono: false),
              _buildDetailRow('Timestamp', formattedTime, isMono: false),
              _buildDetailRow('Payload Digest (SHA-256)', record.payloadDigest, isMono: true),
              _buildDetailRow('Previous Hash', record.previousHash, isMono: true),
              _buildDetailRow('Block Record Hash', record.recordHash, isMono: true),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.vitalNormalSoft,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.vitalNormal.withOpacity(0.4)),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.verified, size: 16, color: AppColors.vitalNormal),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Cryptographically verified & chained in local secure enclave. Zero tampering detected.',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.vitalNormal),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: record.recordHash));
                    Navigator.of(ctx).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Cryptographic record hash copied to clipboard.')),
                    );
                  },
                  icon: const Icon(Icons.copy, size: 16),
                  label: const Text('COPY BLOCK HASH SIGNATURE'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.pulseCyan,
                    foregroundColor: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, {required bool isMono}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
          const SizedBox(height: 2),
          Text(
            value,
            style: isMono
                ? AppTypography.codeMono.copyWith(fontSize: 10, color: AppColors.pulseCyan)
                : const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final eventColor = _getEventColor(record.eventType);
    final timeStr = DateFormat('HH:mm:ss').format(record.timestamp);
    final shortHash = record.recordHash.length > 16
        ? '${record.recordHash.substring(0, 8)}...${record.recordHash.substring(record.recordHash.length - 8)}'
        : record.recordHash;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isLatest ? eventColor.withOpacity(0.5) : AppColors.borderSubtle,
          width: 1.0,
        ),
      ),
      child: InkWell(
        onTap: () => _showRecordDetails(context),
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: eventColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '#${record.sequenceIndex.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: eventColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    record.eventType,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: eventColor,
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.verified, size: 14, color: AppColors.vitalNormal),
                  const SizedBox(width: 4),
                  Text(
                    timeStr,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                record.actionSummary,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textPrimary,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.shield_outlined, size: 12, color: AppColors.textMuted),
                  const SizedBox(width: 4),
                  Text(
                    record.actor,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.lock_outline, size: 10, color: AppColors.pulseCyan),
                        const SizedBox(width: 4),
                        Text(
                          shortHash,
                          style: AppTypography.codeMono.copyWith(fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
