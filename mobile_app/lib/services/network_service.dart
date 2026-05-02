import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkService {
  static final NetworkService _instance = NetworkService._internal();
  factory NetworkService() => _instance;
  NetworkService._internal();

  /// Check if device has internet connection
  Future<bool> hasInternet() async {
    final result = await Connectivity().checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }

  /// Stream to listen to connectivity changes
  Stream<bool> get onConnectivityChanged {
    return Connectivity().onConnectivityChanged.map(
      (results) => !results.contains(ConnectivityResult.none)
    );
  }
}