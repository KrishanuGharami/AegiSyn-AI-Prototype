import 'package:flutter/material.dart';
import '../models/telemetry_point.dart';
import '../core/constants/app_colors.dart';

class WaveformPainter extends CustomPainter {
  final List<TelemetryPoint> history;
  final Color lineColor;
  final bool showGrid;

  WaveformPainter({
    required this.history,
    required this.lineColor,
    this.showGrid = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    // 1. Draw authentic ICU monitor grid background
    if (showGrid) {
      final gridPaint = Paint()
        ..color = AppColors.gridLine
        ..strokeWidth = 1.0;

      const gridSpacing = 20.0;
      for (double x = 0; x < size.width; x += gridSpacing) {
        canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
      }
      for (double y = 0; y < size.height; y += gridSpacing) {
        canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
      }
    }

    if (history.isEmpty) return;

    // 2. Waveform Stroke & Fill
    final paint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          lineColor.withOpacity(0.20),
          lineColor.withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final path = Path();
    final fillPath = Path();

    // Scale heart rates dynamically with safe defaults (zero-allocation loop)
    double minHr = history.first.heartRate;
    double maxHr = history.first.heartRate;
    for (int i = 1; i < history.length; i++) {
      final hr = history[i].heartRate;
      if (hr < minHr) minHr = hr;
      if (hr > maxHr) maxHr = hr;
    }
    minHr -= 6;
    maxHr += 6;
    final range = (maxHr - minHr) > 12 ? (maxHr - minHr) : 12;

    final stepX = size.width / (history.length - 1).clamp(1, 100);

    for (int i = 0; i < history.length; i++) {
      final x = i * stepX;
      final normalized = (history[i].heartRate - minHr) / range;
      final y = size.height - (normalized * (size.height * 0.72) + size.height * 0.14);

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        final prevX = (i - 1) * stepX;
        final prevNorm = (history[i - 1].heartRate - minHr) / range;
        final prevY = size.height - (prevNorm * (size.height * 0.72) + size.height * 0.14);

        final midX = (prevX + x) / 2;
        path.cubicTo(midX, prevY, midX, y, x, y);
        fillPath.cubicTo(midX, prevY, midX, y, x, y);
      }

      if (i == history.length - 1) {
        fillPath.lineTo(x, size.height);
        fillPath.close();
      }
    }

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);

    // 3. Glowing live scanning indicator at the right tip
    if (history.isNotEmpty) {
      final lastNorm = (history.last.heartRate - minHr) / range;
      final lastY = size.height - (lastNorm * (size.height * 0.72) + size.height * 0.14);
      final lastX = (history.length - 1) * stepX;

      final dotPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;

      final pulseHalo = Paint()
        ..color = lineColor.withOpacity(0.5)
        ..style = PaintingStyle.fill;

      final wideHalo = Paint()
        ..color = lineColor.withOpacity(0.2)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(lastX, lastY), 10.0, wideHalo);
      canvas.drawCircle(Offset(lastX, lastY), 5.5, pulseHalo);
      canvas.drawCircle(Offset(lastX, lastY), 2.5, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant WaveformPainter oldDelegate) {
    return oldDelegate.history != history || oldDelegate.lineColor != lineColor;
  }
}
