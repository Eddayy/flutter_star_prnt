import 'dart:async';

import 'package:flutter/services.dart';

class FlutterStarPrnt {
  static const MethodChannel _channel =
      const MethodChannel('flutter_star_prnt');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<dynamic> portDiscovery(String type) async {
    try {
      return await _channel.invokeMethod('portDiscovery', {'type': type});
    } on PlatformException catch (err) {
      print("Error  ${err.message}");
      // Handle err
    } catch (err) {
      // other types of Exceptions
    }
  }
}
