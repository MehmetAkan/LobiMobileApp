import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Network connectivity status
enum NetworkStatus {
  online,
  offline,
  unknown, // Initial/permission pending
}

/// Global connectivity stream provider
/// Monitors real-time network status changes
final connectivityStreamProvider = StreamProvider<NetworkStatus>((ref) {
  return Connectivity().onConnectivityChanged.map((results) {
    // v7.0.0 returns List<ConnectivityResult>
    if (results.contains(ConnectivityResult.none)) {
      return NetworkStatus.offline;
    } else if (results.contains(ConnectivityResult.mobile) ||
        results.contains(ConnectivityResult.wifi) ||
        results.contains(ConnectivityResult.ethernet)) {
      return NetworkStatus.online;
    } else {
      return NetworkStatus.unknown;
    }
  });
});

/// Current network status (sync access)
final connectivityProvider = Provider<NetworkStatus>((ref) {
  final asyncValue = ref.watch(connectivityStreamProvider);
  return asyncValue.when(
    data: (status) => status,
    loading: () => NetworkStatus.unknown,
    error: (_, __) => NetworkStatus.unknown,
  );
});

/// Check if currently online
final isOnlineProvider = Provider<bool>((ref) {
  final status = ref.watch(connectivityProvider);
  return status == NetworkStatus.online;
});
