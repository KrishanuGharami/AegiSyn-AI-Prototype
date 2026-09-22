import 'package:aegisyn_ai/models/telemetry_point.dart';
import '../interfaces.dart';

class SignalAgent implements SignalAnalyzer {
  final String agentId = 'AegiSyn-SignalAgent-v1.4';

  @override
  TelemetryPoint filterAndSmooth(TelemetryPoint raw, List<TelemetryPoint> recentWindow) {
    if (recentWindow.isEmpty) return raw;

    final samples = [...recentWindow.take(3), raw];
    final avgHr = samples.map((s) => s.heartRate).reduce((a, b) => a + b) / samples.length;
    final avgSpo2 = samples.map((s) => s.spO2).reduce((a, b) => a + b) / samples.length;
    final avgResp = samples.map((s) => s.respirationRate).reduce((a, b) => a + b) / samples.length;

    return raw.copyWith(
      heartRate: double.parse(avgHr.toStringAsFixed(1)),
      spO2: double.parse(avgSpo2.toStringAsFixed(1)),
      respirationRate: double.parse(avgResp.toStringAsFixed(1)),
    );
  }

  @override
  bool isSignalQualityAcceptable(TelemetryPoint point) {
    return point.signalQuality >= 0.70;
  }

  @override
  Map<String, double> computeSignalDeltas(TelemetryPoint current, TelemetryPoint baseline) {
    return {
      'deltaHR': current.heartRate - baseline.heartRate,
      'deltaSpO2': current.spO2 - baseline.spO2,
      'deltaResp': current.respirationRate - baseline.respirationRate,
      'deltaSysBP': current.systolicBp - baseline.systolicBp,
    };
  }
}
