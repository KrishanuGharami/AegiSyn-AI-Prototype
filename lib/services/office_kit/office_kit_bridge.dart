import 'dart:async';
import '../../models/routing_decision.dart';

enum OfficeKitConnectionState {
  disconnected,
  connecting,
  connected,
  transmitting,
  syncAcknowledged,
}

class OfficeKitCapabilities {
  final bool multiScreenMirroring;
  final bool crossDeviceClipboard;
  final bool highThroughputTelemetryStream;
  final bool instantClinicalHandover;

  const OfficeKitCapabilities({
    this.multiScreenMirroring = true,
    this.crossDeviceClipboard = true,
    this.highThroughputTelemetryStream = true,
    this.instantClinicalHandover = true,
  });
}

class OfficeKitSyncEvent {
  final DateTime timestamp;
  final String title;
  final String description;
  final String rawPacketDump;

  const OfficeKitSyncEvent({
    required this.timestamp,
    required this.title,
    required this.description,
    required this.rawPacketDump,
  });
}

abstract class OfficeKitBridge {
  OfficeKitConnectionState get connectionState;
  OfficeKitCapabilities get capabilities;
  bool get isDevelopmentFallback;
  String get peerDeviceName;
  List<OfficeKitSyncEvent> get syncHistory;
  Future<bool> connect();
  Future<bool> disconnect();
  Future<bool> transmitClinicalHandover(RoutingDecision decision);
}

class SimulatedOfficeKitBridge implements OfficeKitBridge {
  OfficeKitConnectionState _state = OfficeKitConnectionState.connected;
  final List<OfficeKitSyncEvent> _history = [];
  final String _peerName = 'iQOO Neo Workstation • Hyderabad ICU Station B';

  SimulatedOfficeKitBridge() {
    _initDemoHistory();
  }

  void _initDemoHistory() {
    _history.add(
      OfficeKitSyncEvent(
        timestamp: DateTime.now().subtract(const Duration(minutes: 8)),
        title: 'Office Kit Peer Paired',
        description: 'P2P protocol handshake completed with $_peerName.',
        rawPacketDump: '{"channel": "P2P_DIRECT", "mtu": 65535, "cipher": "AES_GCM_256", "peer": "iQOO_WORKSTATION_04"}',
      ),
    );
  }

  @override
  OfficeKitConnectionState get connectionState => _state;

  @override
  OfficeKitCapabilities get capabilities => const OfficeKitCapabilities();

  @override
  bool get isDevelopmentFallback => true; // Explicitly labeled as development/demo mode

  @override
  String get peerDeviceName => _peerName;

  @override
  List<OfficeKitSyncEvent> get syncHistory => List.unmodifiable(_history);

  @override
  Future<bool> connect() async {
    _state = OfficeKitConnectionState.connecting;
    await Future.delayed(const Duration(milliseconds: 300));
    _state = OfficeKitConnectionState.connected;
    return true;
  }

  @override
  Future<bool> disconnect() async {
    _state = OfficeKitConnectionState.disconnected;
    return true;
  }

  @override
  Future<bool> transmitClinicalHandover(RoutingDecision decision) async {
    _state = OfficeKitConnectionState.transmitting;

    // Simulate cross-device dispatch latency
    await Future.delayed(const Duration(milliseconds: 250));

    _history.insert(
      0,
      OfficeKitSyncEvent(
        timestamp: DateTime.now(),
        title: 'Clinical Handover Dispatched',
        description: 'Priority ${decision.priority.name.toUpperCase()} alert forwarded to Workstation screen for: ${decision.recipients.join(", ")}.',
        rawPacketDump: '{"decisionId": "${decision.id}", "recipients": ${decision.recipients}, "status": "ACK_SUCCESS"}',
      ),
    );

    _state = OfficeKitConnectionState.syncAcknowledged;
    return true;
  }
}
