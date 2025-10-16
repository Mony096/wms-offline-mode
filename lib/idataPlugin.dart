import 'package:flutter/services.dart';

class IdataPlugin {
  static const _channel = MethodChannel('idata_plugin');

  static void startScan({
    required void Function(String result) onScan,
  }) {
    // Listen for scan results from Android
    _channel.setMethodCallHandler((call) async {
      print("asas");
      if (call.method == 'onScanResult') {
        final result = call.arguments as String;
        onScan(result);
      }
    });

    _channel.invokeMethod('startScan');
  }

  static void stopScan() {
    _channel.invokeMethod('stopScan');
  }
}
