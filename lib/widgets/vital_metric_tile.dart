import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_typography.dart';

class VitalMetricTile extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final IconData icon;
  final Color accentColor;
  final bool isAbnormal;
  final String? deltaSubtitle;

  const VitalMetricTile({
    super.key,
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
    this.accentColor = AppColors.pulseCyan,
    this.isAbnormal = false,
    this.deltaSubtitle,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = isAbnormal ? AppColors.alertHigh : accentColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isAbnormal ? AppColors.alertHigh.withOpacity(0.6) : AppColors.borderSubtle,
          width: isAbnormal ? 1.5 : 1.0,
        ),
        boxShadow: isAbnormal
            ? [
                BoxShadow(
                  color: AppColors.alertHigh.withOpacity(0.18),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                )
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: effectiveColor),
              const SizedBox(width: 6),
              Text(
                label.toUpperCase(),
                style: AppTypography.metricLabel.copyWith(
                  color: isAbnormal ? AppColors.alertHigh : AppColors.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              if (isAbnormal)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.alertHigh.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'DEV',
                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.alertHigh),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: AppTypography.metricValue.copyWith(
                  color: isAbnormal ? AppColors.alertHigh : AppColors.textPrimary,
                  fontSize: 22,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                unit,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
          if (deltaSubtitle != null) ...[
            const SizedBox(height: 3),
            Text(
              deltaSubtitle!,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: isAbnormal ? AppColors.alertHigh : AppColors.vitalNormal,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}
