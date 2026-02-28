import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class NetworkService {
  static Future<bool> get isConnected async {
    return await InternetConnection().hasInternetAccess;
  }
}
