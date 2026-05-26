import 'package:connectivity_plus/connectivity_plus.dart';

abstract class NetworkInfo {
  Future<bool> get isConnected;
}

class NetworkInfoImpl implements NetworkInfo {
  const NetworkInfoImpl({required this.connectivity});
  final Connectivity connectivity;

  @override
  Future<bool> get isConnected async {
    final result = await connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }
}
