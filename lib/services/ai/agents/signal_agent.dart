import 'package:aegisyn_ai/models/telemetry_point.dart';
import '../interfaces.dart';

class SignalAgent implements SignalAnalyzer {
  final String agentId = 'AegiSyn-SignalAgent-v1.4';

  @override
  TelemetryPoint filterAndSmooth(TelemetryPoint raw, List<TelemetryPoint> recentWindow) {
    if (recentWindow.isEmpty) return raw;

    double sumHr = raw.heartRate;
    double sumSpo2 = raw.spO2;
    double sumResp = raw.respirationRate;
    final count = recentWindow.length > 3 ? 3 : recentWindow.length;
    for (int i = 0; i < count; i++) {
      sumHr += recentWindow[i].heartRate;
      sumSpo2 += recentWindow[i].spO2;
      sumResp += recentWindow[i].respirationRate;
    }
    final total = count + 1;

    return raw.copyWith(
      heartRate: double.parse((sumHr / total).toStringAsFixed(1)),
      spO2: double.parse((sumSpo2 / total).toStringAsFixed(1)),
      respirationRate: double.parse((sumResp / total).toStringAsFixed(1)),
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
