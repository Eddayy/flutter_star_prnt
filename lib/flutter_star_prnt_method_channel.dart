import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_star_prnt_platform_interface.dart';

/// An implementation of [FlutterStarPrntPlatform] that uses method channels.
class MethodChannelFlutterStarPrnt extends FlutterStarPrntPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_star_prnt');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
