import 'package:connectivity_plus/connectivity_plus.dart';

/// Check Internet connection, and display in a Toast if it's goes away.
Future<bool> hasInternetConnection() async {
  final result = await Connectivity().checkConnectivity();
  return result != ConnectivityResult.none;
}